extends Spatial

var camera = null
var camera_position = Vector3()
var mesh_collection = []

func _ready():
	get_tree().connect("node_added", self, "NodeAddedToTree")
	yield(get_tree(), "idle_frame")
	GetMeshInstances(self, mesh_collection)
	camera = get_tree().root.get_viewport().get_camera()

func GetMeshInstances(var starting_node, var collection):
	for child in starting_node.get_children():
		if child is MeshInstance and (child.lod_min_distance != 0.0 or child.lod_max_distance != 0.0):
			collection.append(weakref(child))
		GetMeshInstances(child, collection)

func _process(delta):
	if camera == null:
		return
	
	var new_position = camera.global_transform.origin
	if new_position.distance_to(camera_position) > 0.25:
		UpdateLOD()
		camera_position = new_position

func NodeAddedToTree(var node):
	GetMeshInstances(node, mesh_collection)

func UpdateLOD():
	for ref in mesh_collection:
		var mesh = ref.get_ref()
		if mesh == null:
			mesh_collection.erase(ref)
			continue
		var distance_to_camera = mesh.global_transform.origin.distance_to(camera_position)
		if distance_to_camera >= mesh.lod_min_distance and (distance_to_camera < mesh.lod_max_distance or mesh.lod_max_distance == 0.0):
			mesh.visible = true
		else:
			mesh.visible = false
