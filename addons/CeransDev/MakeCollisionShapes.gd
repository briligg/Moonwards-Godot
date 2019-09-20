tool
extends EditorScript

func obj_add_col_trimesh(obj):
	obj.create_trimesh_collision()

func obj_add_col_convex(obj):
	obj.create_convex_collision()

func obj_add_col(obj):
	obj_add_col_trimesh(obj)

func obj_has_col(node):
	var has = false
	for obj in node.get_children():
		if obj.get_class() == "StaticBody":
			has = true
			break
	return has

func obj_get_file(obj):
	var name = ""
	return name

func obj_get_name(obj):
	var fname = get_scene().filename.replace("res://", "").replace(".tscn", "")
	var name = String(get_scene().get_path_to(obj)).replace("/", ".")
	return fname + "." + name

func obj_res_name(obj, name = ""):
	match obj.get_class():
		"CollisionShape":
			name += "cs." + obj_get_name(obj) + ".shape"
	return name

func make_collision_shapes(nodes):
	for obj in nodes:
		if obj.get_class() == "MeshInstance":
			if not obj_has_col(obj):
				obj_add_col(obj)
	pass

func shapes_save(nodes, path = "res://shapes/"):
	for obj in nodes:
		if obj.get_class() == "CollisionShape":
			print(path + obj_res_name(obj))
			print(obj.shape.resource_path)
			var res_path = path + obj_res_name(obj)
			if obj.shape.resource_path != res_path:
				ResourceSaver.save(res_path, obj.get_shape())
				obj.shape.resource_path = res_path
			else:
				print("already saved")
		shapes_save(obj.get_children())
		
func get_all_meshes(node):
	var meshes = []
	var array2 =[]
	for child in node.get_children():
		print(child)
		if child is MeshInstance:
			meshes.append(child)
		if child.get_child_count() > 1:
			array2 = get_all_meshes(child)
			for element in array2:
				meshes.append(element)
	if meshes.size() != 0:
		return meshes
	else: 
		print("Non fatal array error: Array is empty")
		
func _run():
	var scene = get_scene()
	make_collision_shapes(get_all_meshes(scene))
	shapes_save(get_all_meshes(scene))
