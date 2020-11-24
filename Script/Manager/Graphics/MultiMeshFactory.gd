extends Node

class MeshFactoryData:
	extends Reference
	var mesh: Mesh
	var transform_arr: Array
	
# Dictionary for runtime generated multimesh instances
# Key: Mesh source path
# Value: Array of Transforms
var multimesh_data_arr = {}

var multimesh_instances = {}

func _ready() -> void:
	Signals.Loading.connect(Signals.Loading.WORLD_ON_READY, self, "_world_on_ready")
	
func _world_on_ready():
	generate_multimeshes()

func add_mesh_data(mesh_path: String, transform: Transform):
	if multimesh_data_arr.has(mesh_path):
		multimesh_data_arr[mesh_path].transform_arr.append(transform)
	else:
		var _mesh = load(mesh_path)
		var data = MeshFactoryData.new()
		data.transform_arr.append(transform)
		data.mesh = _mesh
		multimesh_data_arr[mesh_path] = data

func generate_multimeshes():
	var world = get_tree().get_root().get_node("world")
	for factory_data in multimesh_data_arr.values():
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
		multimesh_instance.name = factory_data.mesh.resource_name
		multimesh_instance.multimesh = _multimesh
		world.add_child(multimesh_instance)
