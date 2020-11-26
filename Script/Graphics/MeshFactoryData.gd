extends Reference
class_name MeshFactoryData

var mesh: Mesh
# The minimum amount of instances to convert to multimesh
var minimum_count: int = 4
# The node in which to place the multimesh
var spawn_path: String = ""
var transform_arr: Array
# Array of instances to remove, if this becomes eligible to become a multimesh
var instance_arr: Array

var lod_level: String

func remove_instances():
	for instance in instance_arr:
		instance.queue_free()
