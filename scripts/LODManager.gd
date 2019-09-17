extends Node
var id = "LodManager"

export(float) var grid_step = 10
export(bool) var enabled = true setget lod_enable
export(NodePath) var scene_path setget set_scene_path

var camera = null
var camera_position = Vector3()
var mesh_collection = []
var id_collection = {}

func printd(s):
	logg.print_filtered_message(id, s)

func _ready():
	printd("_ready, enabled(%s)" % enabled)
	if enabled:
		enabled = false
		lod_enable(true)

func lod_enable(turn_on):
	printd("lod_enable: %s %s" % [turn_on, enabled])
	if turn_on and not enabled:
		printd("Enable LodManager, at %s" % get_lodroot().get_path())
		if get_tree():
			get_tree().connect("node_added", self, "NodeAddedToTree")
			enabled = true
			reset()
		else:
			print("Failed to enable lod manager, get_tree is null")
	elif not turn_on and enabled:
		printd("Disable LodManager")
		if get_tree():
			get_tree().disconnect("node_added", self, "NodeAddedToTree")
		enabled = false
		reset(false)

func get_lodroot():
	if scene_path:
		return get_node(scene_path)
	else:
		return get_parent()

func reset(init=true):
	printd("reset(%s)" % init)
	camera = null
	camera_position = Vector3()
	if mesh_collection.size() > 0:
		printd("Restore state")
		for ref in mesh_collection:
			var obj = ref.get_ref()
			var id = obj.get_instance_id()
			printd("rs_mesh %s %s %s %s" % [id, obj.get_path(), obj.visible, id_collection[id].visible])
			if id_collection.has(id) and obj.visible != id_collection[id].visible:
				obj.visible = id_collection[id].visible
	
	mesh_collection = []
	id_collection = {}
	if init:
		init_scene()

func init_scene():
	printd("init_scene")
	yield(get_tree(), "idle_frame")
	GetMeshInstances(get_lodroot(), mesh_collection)
	camera = get_tree().root.get_viewport().get_camera()
	
	if camera:
		UpdateLOD(true)
	else:
		printd("init_scene, no camera found")

func set_scene_path(path):
	set_scene_path_update(path, false)

func set_scene_path_update(path, force_update=false): 
	if not enabled:
		scene_path = path
		return
	if scene_path != path:
		printd("scene_path, path changed %s -> %s" % [scene_path, path])
		scene_path = path
		reset(true)
	else:
		UpdateLOD(true)

func GetMeshInstances(var starting_node, var collection):
	#consider that starting_nodes can be object of managment as well
	var sid = starting_node.get_instance_id()
	var nodes = starting_node.get_children()
	nodes.append(starting_node)
	for child in nodes:
		var id = child.get_instance_id()
		if child is MeshInstance and (child.lod_min_distance != 0.0 or child.lod_max_distance != 0.0) and not (child.lod_min_distance > child.lod_max_distance):
			if not id_collection.has(id):
				collection.append(weakref(child))
				id_collection[id] = {
					visible = child.visible
					}
		if id != sid:
			GetMeshInstances(child, collection)

func _process(delta):
	if not enabled:
		return
	if camera==null:
		#as soon as we get camera, force update
		if UpdateCamera(true):
			printd("_process, camera found, update first time")
			UpdateLOD(true)
	elif UpdateCamera():
		UpdateLOD()

func NodeAddedToTree(var node):
	if get_lodroot().is_a_parent_of(node):
		GetMeshInstances(node, mesh_collection)

func UpdateCamera(force=false):
	camera = get_tree().root.get_viewport().get_camera()
	if camera == null:
		return false

	var new_position = camera.global_transform.origin
	if force or new_position.distance_to(camera_position) > grid_step:
		camera_position = new_position
		return true
	return false

func UpdateLOD(force=false):
	if force:
		printd("force UpdateLOD")
		var uc = UpdateCamera(force)
		if not uc :
			printd("UpdateLOD no camera position defined")
			return
		
	#printd("LODManager update, collection size %s, position %s" %  [mesh_collection.size(), camera_position])
	var changes = 0
	var visible = 0
	var hidden = 0
	for ref in mesh_collection:
		var mesh = ref.get_ref()
		if mesh == null:
			mesh_collection.erase(ref)
			continue
		var distance_to_camera = mesh.global_transform.origin.distance_to(camera_position)
# 		printd("dd %s %s %s %s min/max/distance_to_camera/visible %s " % [mesh.lod_min_distance, mesh.lod_max_distance, distance_to_camera, mesh.visible, mesh.get_path()])
		var new_visible = false
		if distance_to_camera >= mesh.lod_min_distance and (distance_to_camera < mesh.lod_max_distance or mesh.lod_max_distance == 0.0):
			new_visible = true

		if mesh.visible and not new_visible:
			changes += 1
# 			printd("mesh(%s), %s distance(%s) visible(%s, %s) %s %s" % [mesh, mesh.get_path(), distance_to_camera, mesh.visible, new_visible, mesh.lod_min_distance, mesh.lod_max_distance])
		elif not mesh.visible and new_visible:
			changes += 1
# 			printd("mesh(%s), %s distance(%s) visible(%s, %s) %s %s" % [mesh, mesh.get_path(), distance_to_camera, mesh.visible, new_visible, mesh.lod_min_distance, mesh.lod_max_distance])

		if mesh.visible and not new_visible:
			mesh.visible = false
		elif not mesh.visible and new_visible:
			mesh.visible = true
		if mesh.visible:
			visible += 1
		else:
			hidden += 1
	if changes > 0:
		printd("LM %s/%s/%s/%s changes/visible/hidden/total" % [changes, visible, hidden, mesh_collection.size()])
