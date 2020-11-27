extends Node
# Dictionary for runtime generated multimesh instances
# Key: Mesh source path
# Value: Array of Transforms
var multimesh_data_arr = {}

var multimesh_instances = {}

func _ready() -> void:
	Signals.Loading.connect(Signals.Loading.WORLD_ON_READY, self, "_world_on_ready")
	
func _world_on_ready():
	generate_multimeshes()

func add_mesh_data(mesh: Mesh, mesh_instance: Node, transform: Transform, 
		lod_level: String, minimum_count):

	var mesh_name = mesh.resource_name
	var factory_data
	if multimesh_data_arr.has(mesh_name):
		factory_data = multimesh_data_arr[mesh_name]
	else:
		factory_data = MeshFactoryData.new()
		multimesh_data_arr[mesh_name] = factory_data
	
	factory_data.transform_arr.append(transform)
	factory_data.mesh = mesh
	if mesh_instance:
		factory_data.instance_arr.append(mesh_instance)
	factory_data.lod_level = lod_level
	factory_data.minimum_count = minimum_count

func generate_multimeshes():
	for factory_data in multimesh_data_arr.values():
#		if factory_data.transform_arr.size() < factory_data.minimum_count:
#			continue
#		_remove_mesh_instances(factory_data)
		var spawn_node 
		if !factory_data.spawn_path.empty():
			spawn_node = get_node(factory_data.spawn_path)
		else:
			Log.warning(self, "generate_multimeshes", "Spawn path not specified for %s" 
					%factory_data.mesh.resource_name)
			spawn_node = get_tree().get_root().get_node("world")

		_verify_spawn_node_lods(spawn_node)

		var _multimesh = MultiMesh.new()
		_multimesh.mesh = factory_data.mesh
		_multimesh.transform_format = MultiMesh.TRANSFORM_3D
		_multimesh.color_format = MultiMesh.COLOR_FLOAT
		_multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
		_multimesh.instance_count = factory_data.transform_arr.size()
		_multimesh.visible_instance_count = factory_data.transform_arr.size()
		
		for i in _multimesh.visible_instance_count:
			_multimesh.set_instance_transform(
				i, factory_data.transform_arr[i]
			)
			
		var multimesh_instance = MultiMeshInstance.new()
		multimesh_instance.name = "MMC%s" %factory_data.mesh.resource_name
		multimesh_instance.multimesh = _multimesh
		if factory_data.lod_level:
			spawn_node.get_node(factory_data.lod_level).add_child(multimesh_instance)
		else:
			spawn_node.add_child(multimesh_instance)

func _verify_spawn_node_lods(spawn_node):
		if spawn_node.get_node_or_null("LOD0") == null:
			var n = Spatial.new()
			n.name = "LOD0"
			spawn_node.add_child(n)
		if spawn_node.get_node_or_null("LOD1") == null:
			var n = Spatial.new()
			n.name = "LOD1"
			spawn_node.add_child(n)
		if spawn_node.get_node_or_null("LOD2") == null:
			var n = Spatial.new()
			n.name = "LOD2"
			spawn_node.add_child(n)
		if spawn_node.get_node_or_null("NOLOD") == null:
			var n = Spatial.new()
			n.name = "NOLOD"
			spawn_node.add_child(n)

func _remove_mesh_instances(factory_data):
	var freeable_instances = []
	
	for instance in factory_data.instance_arr:
		if instance.get_child_count() > 0:
			var inst_parent = instance.get_parent()
			# Create and add a new placeholder to replace original instance
			var new_inst = Spatial.new()
			new_inst.global_transform = instance.global_transform
			inst_parent.add_child(new_inst)
			
			for child in instance.get_children():
				Helpers.reparent(child, new_inst, true)
			
			# remove the instance from the tree
			inst_parent.remove_child(instance)
			new_inst.name = inst_parent.name
		freeable_instances.append(instance)
	for freeable in freeable_instances:
		freeable.free()
