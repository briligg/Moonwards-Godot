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

func add_mesh_data(mesh_path: String, transform: Transform, lod_level):
	if multimesh_data_arr.has(mesh_path):
		multimesh_data_arr[mesh_path].transform_arr.append(transform)
	else:
		var _mesh = load(mesh_path)
		var data = MeshFactoryData.new()
		data.transform_arr.append(transform)
		data.mesh = _mesh
		data.lod_level = lod_level
		multimesh_data_arr[mesh_path] = data

func generate_multimeshes():
	for factory_data in multimesh_data_arr.values():
#		if factory_data.transform_arr.size() < factory_data.minimum_count:
#			continue
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
		_multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_FLOAT
		_multimesh.instance_count = factory_data.transform_arr.size()
		_multimesh.visible_instance_count = factory_data.transform_arr.size()
		
		for i in _multimesh.visible_instance_count:
			_multimesh.set_instance_transform(
				i, factory_data.transform_arr[i]
			)
			
		var multimesh_instance = MultiMeshInstance.new()
		multimesh_instance.name = "MultiMesh%s" %factory_data.mesh.resource_name
		multimesh_instance.multimesh = _multimesh
		spawn_node.get_node(factory_data.lod_level).add_child(multimesh_instance)
		

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
