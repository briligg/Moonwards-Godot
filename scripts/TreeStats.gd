extends Node

var scene setget set_scene

func set_scene(value):
	print("TreeStats set scene to %s" % value)
	scene = value

func _init(root=null):
	if root == null:
		if get_tree():
			scene = get_tree().current_scene
	else:
		scene = root

func id_tree():
	if scene == null:
		return null
	var nodes = utils.get_nodes(scene, true)
	nodes.sort()
	var id = ""
	for p in nodes:
		id += String(p).md5_text()
	return id.md5_text()

func st_node_count():
	if scene == null:
		return null
	return utils.get_nodes(scene, true).size()

func st_mesh_count():
	if scene == null:
		return null
	return utils.get_nodes_type(scene, "MeshInstance", true).size()

func st_mesh_lod_set(lodset=true):
	if scene == null:
		return
	return get_meshlist_lod(lodset).size()

func print_stats():
	print("Tree(%s) id: %s" % [scene, id_tree()])
	print("Total node count: %s" % st_node_count())
	print("Total mesh count: %s" % st_mesh_count())
	print("Total lod set count: %s" % st_mesh_lod_set())
	print("Total no lod count: %s" % st_mesh_lod_set(false))

func get_meshlist_lod(lodset=true):
	var nodes = []
	if scene == null:
		return nodes

	for p in utils.get_nodes_type(scene, "MeshInstance", true):
		var obj = scene.get_node(p)
		if lodset:
			if obj.lod_min_distance > 0 or obj.lod_max_distance > 0:
				nodes.append(p)
		else:
			if obj.lod_min_distance == 0 and obj.lod_max_distance == 0:
				nodes.append(p)
	return nodes
