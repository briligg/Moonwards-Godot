extends Node

var scene setget , get_scene

func _input(var event):
	if event.is_action_pressed("screenshot_key"):
		CreateScreenshot()

func CreateScreenshot():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Let two frames pass to make sure the screen was captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Retrieve the captured image
	var image = get_viewport().get_texture().get_data()
	
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	var date_time = OS.get_datetime()
	image.save_png("user://screenshot_" + str(date_time.year) + str(date_time.month) + str(date_time.day) + str(date_time.hour) + str(date_time.minute) + str(date_time.second) + ".png")

func array_add(a, b):
	for i in b:
		a.append(i)
	return a

func obj_has_groups(obj, groups):
	var has = false
	for grp in groups:
		if obj.get_groups().has(grp):
			has = true
			break
	return has

func obj_has_property(obj, pstr):
	var has = false
	if obj == null:
		return has
	
	var plist = obj.get_property_list()
	var pnames = []
	for pl in plist:
		pnames.append(pl.name)
	
	has = pnames.has(pstr)
	return has

func get_nodes(root, recurent=false):
	var nodes = []
	var objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj.filename:
			if recurent:
				array_add(objects, obj.get_children())
		else:
			array_add(objects, obj.get_children())
		nodes.append(root.get_path_to(obj))
	return nodes

func get_nodes_type(root, type, recurent=false):
	var nodes = get_nodes(root, recurent)
	var result = []
	for path in nodes:
		if root.get_node(path).get_class() == type :
			result.append(path)
	return result


func get_scene():
	return get_tree().current_scene

######################################
#based on CernansDev.gd
#	get collision shapes created by plugin
#

var cs_options = {
	cs_skip_branch = ["cs_none" ],
	cs_skip = [ "cs_manual" ],
	cs_groups = [ "cs", "cs_convex", "floor", "wall"],
	cs_convex = ["cs_convex"],
	cs_trimesh = ["cs", "floor", "wall"],
	bakedlight = {path = "lightmaps", ext = "_bldata.res" },
	material_dir = "res://materials",
	mesh_dir = "meshes",
	cs_dir = "cshapes",
	
	hide_protect = ["floor", "wall"]
}

func get_cs_list(root):
	var meshes = {
			convex = [],
			trimesh = []
		}
	var objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj_has_groups(obj, cs_options.cs_skip_branch):
			continue
		if obj.get_child_count():
			array_add(objects, obj.get_children())
		if obj_has_groups(obj, cs_options.cs_skip):
			continue
		if obj_has_groups(obj, cs_options.cs_convex):
			meshes.convex.append(root.get_path_to(obj))
		elif obj_has_groups(obj, cs_options.cs_trimesh):
			meshes.trimesh.append(root.get_path_to(obj))
	return meshes

func get_cs_list_cs(root):
	# get collision nodes of meshes marked by us for collision, exclude areas and all that stuff
	# important for saving of those meshes
	
	var meshes = get_cs_list(root)
	var paths = []
	array_add(paths, meshes.convex)
	array_add(paths, meshes.trimesh)
	var nodes = []
	for path in paths:
		var obj = root.get_node(path)
		var css = get_nodes_type(obj, 'CollisionShape')
		for cspath in css:
			var o = obj.get_node(cspath)
			nodes.append(root.get_path_to(o))
	return nodes

var cache_flist = {}
func file_mtime(fname):
	# by default handle path's like that 
	# res://_tests/scene_mp/multiplayer_test_scene.tscn::7
	var path = fname.rsplit("::")[0]
	if not cache_flist.has(path):
		var ff = File.new()
		if ff.file_exists(path):
			cache_flist[path] = { mtime = ff.get_modified_time(path) }
		else:
			printd("attempt to get mtime of non existing file '%s'" % path)
			cache_flist[path] = { mtime = "nofile" }
	return cache_flist[path].mtime

func feature_check_server():
	return OS.has_feature("Server")

func feature_check_updater():
	return OS.has_feature("updater")

func get_node_file(node):
	node = get_node_root(node)
	var filename
	if node:
		filename = node.filename
	return filename

func get_node_root(node):
	if node is String:
		node = get_tree().get_node(node)
	while node != null and (node.filename == null or node.filename == ""):
		node = node.get_parent()
	return node

#########################
var debug_id = "utils.gd"
func printd(s):
	logg.print_filtered_message(debug_id, s)
	
	
func get_safe_bool(obj, propetry):
	if obj_has_property(obj, propetry):
		return obj.get(propetry)
	else:
		return false
