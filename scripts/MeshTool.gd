extends Node
var id = "MeshTool"

var mesh setget set_mesh, get_mesh
var mesh_info = {}
var mesh_cache = {}
var root

func printd(s):
	logg.print_filtered_message(id, s)

func cache_has_id(id):
	if id == null:
		return false
	return mesh_cache.has(id)

func cache_has_mesh(mesh, erase=false):
	var id = id_mesh(mesh)
	var has = cache_has_id(id)
	if erase and has:
		mesh_cache.erase(id)
	return has

func cache_vars(id=null):
	if id == null and mesh != null:
		id = id_mesh(mesh)
		mesh_cache[id] = mesh_info
		return
	
	if id and mesh_cache.has(id):
		mesh_info = mesh_cache[id]
		#print("cache_vars hit %s" % id)
	else:
		mesh_info = {}

func get_cache():
	return mesh_cache

func set_cache(mc):
	mesh_cache = mc
	if mesh != null:
		cache_vars(id_mesh(mesh))

func reset_vars():
	mesh_info = {}

func set_mesh(obj):
	if obj == null:
		printd("set_mesh, obj == null")
		return
	if root == null:
		printd("scene tree is not defined")
	
	cache_vars()
	mesh = null
	if obj is String or obj is NodePath:
		obj = root.get_node(obj)
		if obj == null:
			return
	if obj is MeshInstance:
		mesh = obj.mesh
	if obj is Mesh:
		mesh = obj
	cache_vars(id_mesh(mesh))
	#print("MeshTool(%s)" % mesh)

func get_mesh():
	return mesh

func _init(tree=null, obj=null):
	printd("init(%s, %s)" % [tree, obj])
	if tree == null:
		if get_tree():
			tree = get_tree().current_scene
	root = tree
	set_mesh(obj)

func get_facescount():
	if mesh == null:
		return
	if mesh_info.has("faces_count"):
		return mesh_info.faces_count
	mesh_info["faces_count"] = mesh.get_faces().size()
	return mesh_info.faces_count

func get_median():
	if mesh == null:
		return
	if mesh_info.has("vert_median"):
		return mesh_info.vert_median

	var vsum = Vector3(0, 0, 0)
	var count = 0
	for v in mesh.get_faces():
		vsum += v
		count += 1
	if count > 0:
		vsum /= count
	mesh_info["vert_median"] = vsum
	mesh_info["faces_count"] = count
	return vsum

func get_hitbox():
	if mesh == null:
		printd("get_hitbox mesh is null")
		return
	if mesh_info.has("hitbox"):
		return mesh_info.hitbox
	
	var box  #x, -x y, -y, z, -z
	var fcount = 0
	for v in mesh.get_faces():
		if box == null:
			box = [v.x, v.x, v.y, v.y, v.z, v.z]
			continue
		if v.x > box[0]:
			box[0] = v.x
		if v.x < box[1]:
			box[1] = v.x
		if v.y > box[2]:
			box[2] = v.y
		if v.y < box[3]:
			box[3] = v.y
		if v.z > box[4]:
			box[4] = v.z
		if v.z < box[5]:
			box[5] = v.z
		fcount += 1
	if box == null:
		#mesh with no faces
		box = [0,0,0,0,0,0]
	mesh_info["hitbox"] = [Vector3(box[1], box[3], box[5]), Vector3(box[0] - box[1], box[2] - box[3], box[4] - box[5])]
	mesh_info["faces_count"] = fcount
	return mesh_info["hitbox"]

func get_hitbox_sum(b1=null, b2=null):
	if b1 == null:
		b1 = [Vector3(0,0,0),Vector3(0,0,0)]
	if b2 == null:
		b2 = get_hitbox()
	if b2 == null:
		b2 = [Vector3(0,0,0),Vector3(0,0,0)]
	for k in ["x", "y", "z"]:
		if abs(b1[1][k]) < abs(b2[1][k]):
			b1[1][k] = abs(b2[1][k])
	return b1

func get_hitbox_max(b1):
	var res = 0
	for k in ["x", "y", "z"]:
		if abs(b1[1][k]) > res:
			res = abs(b1[1][k])
	return res

func hbox_volume():
	var bb = get_hitbox()
	if bb == null:
		return 0
	return bb[1].x*bb[1].y*bb[1].z

func hbox_surface():
	var bb = get_hitbox()
	if bb == null:
		return 0
	var hs = bb[1]
	return 2*hs.x*hs.y+2*hs.x*hs.z + 2*hs.y*hs.z

func hbox_surface_projection():
	return hbox_surface()/6

func hbox_instance():
	var cm = CubeMesh.new()
	var bb = get_hitbox()
	cm.size = bb[1]
	return cm

func id_mesh(obj):
	var noid = null
	if obj == null:
		printd("id_mesh, object is null")
		return noid
	if obj is MeshInstance:
		if obj.mesh:
			obj = obj.mesh
		else:
			printd("id_mesh, mesh is null in: %s" % obj.get_path())
			return noid
	if not obj.is_class("Resource"):
		#print("id_mesh obj(%s) not a Resource type" % obj)
		return noid
	var path = obj.resource_path
	var mtime = utils.file_mtime(path)
	var id = "%s %s" % [mtime, path]
# 	printd("id_mesh %s" % id)
	return id.md5_text()
