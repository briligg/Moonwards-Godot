extends Node

var id = "TreeManager"
var enabled = false setget tm_enable
var tree
export(NodePath) var tree_path

export(bool) var enable_lodmanager = true
export(bool) var enable_areamanager = true
export(bool) var enable_boxmesh = true
export(bool) var enable_hboxsetlod = true #set lod values for lod manager based on hitbox of mesh
export(bool) var enable_lodelement = true # looks for LODElement markers, and substitutions, establish relation
var lod_element_group = "LODElement"
var enable_hboxsetlod_save_cache = true
export(float) var lod_aspect_ratio = 10  setget set_lod_aspect_ratio #lod set as projection of hitbox * aspect_ratio


export(NodePath) var LodManager
var scripts = {
	MeshTool = preload("res://scripts/MeshTool.gd"),
	TreeStats = preload("res://scripts/TreeStats.gd")
}
var MeshTool
var TreeStats

func printd(s):
	logg.print_filtered_message(id, s)

#Set root path to manage mesh instances below
func set_path():
	pass

# generate id of a tree mased on timestamps of all files
# do not detect runtime generated changes
func tree_id():
	var id
	if TreeStats:
		id = TreeStats.id_tree()
	return id

func _process(delta):
	#check active camera for the positions
	#call all other managers with new position
	pass

var update_tree = false
func track_node_added(node):
	if update_tree:
		return
	if not node is MeshInstance:
		return
	if String(node.get_path()).begins_with("/root/Control"):
		printd("track_node_added, ignore, part of control %s" % node.get_path())
		return
	if tree and node:
		if tree.has_node(node.get_path()):
			var root = get_tree()
			root.connect("idle_frame", self, "track_update", [], Node.CONNECT_ONESHOT)
			update_tree = true
			printd("TM track node added, set update, cuz %s in %s" % [node.get_path(), tree.get_path()])

func track_node_removed(node):
	if node is MeshInstance and MeshTool:
		#clear cache
		MeshTool.cache_has_mesh(node, true)
	if not update_tree:
		return
	#parent calulated size may change because of removing child nodes, so react on remove too
	if tree and node:
		if tree.has_node(node.get_path()):
			var root = tree.get_tree()
			root.connect("idle_frame", self, "track_update", [], Node.CONNECT_ONESHOT)
			update_tree = true
			printd("TM track node remove, set update, cuz %s in %s" % [node.get_path(), tree.get_path()])

func track_update():
	update_tree = false
	printd("TM track_update")
	if enable_hboxsetlod:
		printd("TM update hboxsetlod at %s" % tree.get_path())
		hboxsetlod(tree)
		if enable_lodelement:
			lodelement_set(tree)


func track_changes(enable):
	printd("TM track_changes(%s) at %s" % [enable, tree])
	var root = get_tree()
	if root:
		if enable:
			root.connect("node_added", self, "track_node_added")
			root.connect("node_removed", self, "track_node_removed")
		else:
			root.disconnect("node_added", self, "track_node_added")
			root.disconnect("node_removed", self, "track_node_removed")
	else:
		printd("fail to setup tracking changes, enable(%s), but get_tree is null" % enable)

func hboxsetlod_check(node):
	var to_set = false
	if node is MeshInstance:
		if node.lod_min_distance == 0 and node.lod_max_distance == 0:
			to_set = true
		else:
			MeshTool.cache_has_mesh(node, true) ##erase from cache if exists
		
		if MeshTool.cache_has_mesh(node):
			to_set = true
	return to_set

func hboxsetlod(node, children = true):
	var size = 0
	if hboxsetlod_check(node):
		MeshTool.mesh = node
		size += MeshTool.hbox_surface_projection()
	if children:
		for child in node.get_children():
			size += hboxsetlod(child, true)
	if size > 0 and hboxsetlod_check(node):
		# do not set lod if it set manually
		var new_lmd = lod_aspect_ratio * sqrt(size)
		# round stuff, as there may be problems like that
		# value rounded in mesh sintance lod
		# old new 4.995999 4.996 path /root/LODTestingTree/@LODMesh@56/Sphere
		# [MeshInstance:1406] lod(4.995999) aspect(10) size(0.2496) 
		# however this one is in reverse
		# old new 288.67514 288.675135 path /root/LODTestingTree/MeshInstance
		# [MeshInstance:1249] lod(288.67514) aspect(10) size(833.333333) 
		# casting to float does not help
		# which is odd
		# TODO
		# comparions needs mostly for being able to print debug changes in sizes
		# so it not necessaly and can be removed later to jsut assing values
		# or track it independantly
		if round(new_lmd*1000) != round(node.lod_max_distance*1000):
			#printd("old new %s %s path %s" % [node.lod_max_distance, new_lmd, node.get_path()])
			node.lod_max_distance = new_lmd
			printd("%s lod(%s) aspect(%s) size(%s) name: %s " % [node, node.lod_max_distance, lod_aspect_ratio, size, node.name])
	return size

func hboxsetlod_set(root):
	if enable_hboxsetlod_save_cache:
		printd("hboxsetlod get cache")
		var cache = options.get("TreeManagerCache")
		if cache != null:
			printd("hboxsetlod get cache")
			MeshTool.set_cache(cache)
	hboxsetlod(root)
	if enable_lodelement:
		lodelement_set(tree)
	if enable_hboxsetlod_save_cache:
		options.set("TreeManagerCache", MeshTool.get_cache())
		#will accumulate changes in dev settings, fix that :TODO :FIX
		printd("hboxsetlod save cache")
		options.save()

func lodelement_weight(node, weight = null):
	if weight == null:
		weight = { size = 0, vcount = 0, hb = [Vector3(0,0,0),Vector3(0,0,0)]}
	if node == null:
		return weight
	var id_mesh = MeshTool.id_mesh(node)
	if id_mesh:
		#count only those which are touched by hbox, and are in cache
		if MeshTool.cache_has_id(id_mesh):
			MeshTool.mesh = node
			weight.size += MeshTool.hbox_surface_projection()
			weight.vcount += MeshTool.get_facescount()
			weight.hb = MeshTool.get_hitbox_sum(weight.hb)

	for n in node.get_children():
		lodelement_weight(n, weight)
	return weight

func lodelement_fixchilds(node):
	for p in utils.get_nodes_type(node, "MeshInstance", true):
		var obj = node.get_node(p)
		if obj.lod_max_distance > node.lod_max_distance:
			printd("fix child lod max %s %s, %s" % [obj.lod_max_distance, node.lod_max_distance, obj.get_path()])
			obj.lod_max_distance = node.lod_max_distance
		if obj.lod_min_distance < node.lod_min_distance:
			if node.lod_min_distance > obj.lod_max_distance:
				printd("won't be shown, too small %s" % obj.get_path())
			printd("fix child lod min %s %s, %s" % [obj.lod_max_distance, node.lod_max_distance, obj.get_path()])
			obj.lod_min_distance = node.lod_min_distance

func lodelement_set(root):
	if root == null:
		printd("lodelement, root is not defined")
		return
	var tree = get_tree()
	if tree == null:
		printd("lodelement tree is null, fail to adjust tree")
		return
	if not enable_hboxsetlod:
		printd("lodelement, hbox lod is disabled, no data for adjusting")
		return
	if not tree.has_group(lod_element_group):
		printd("lodelement, lod_element_group(%s) not found in tree(%s)" % [lod_element_group, tree])
		return
	 
	var loe = tree.get_nodes_in_group(lod_element_group)
	printd("lodelement, found %s nodes" % loe.size())
	for e in loe:
		if not root.has_node(e.get_path()):
			loe.erase(e)
	printd("lodelement, belong to %s %s nodes" % [root.get_path(), loe.size()])
	
	var substitute = "substitute"
	for e in loe:
		printd("loe %s" % [e.get_path()])
		var whom = e.get(substitute)
		if whom:
			printd("whom %s" % [whom])
		else:
			var nroot = utils.get_node_root(e)
			var fname = nroot.filename
			var path = nroot.get_path_to(e)
			printd("substitutions is not defined '%s' in %s::%s" % [whom, fname, path])
			loe.erase(e)
		#weight both branches to determine lod_min and max
		var sweight = lodelement_weight(e.get_sub_node())
		var weight = lodelement_weight(e)
		if weight.vcount < 1:
			weight.vcount = 1
		var proportion = sqrt(sweight.vcount/weight.vcount)
		if proportion > 50:
			printd("weights %s %s" % [sweight, weight])
			printd("node lod %s %s" % [e.get_sub_node().lod_min_distance, e.get_sub_node().lod_max_distance])
			printd("sub  lod %s %s" % [e.lod_min_distance, e.lod_max_distance])
			printd("proportion %s" % proportion)
			printd("proportion is %s in %s, reduced to 50" % [proportion, e.get_path()])
			proportion = 50
		if proportion > 1:
			e.get_sub_node().lod_max_distance = e.lod_max_distance / proportion
			e.lod_min_distance = e.get_sub_node().lod_max_distance
		elif proportion > 0 and proportion < 1:
			#no point in increasing max lod, so 
			e.lod_max_distance = e.get_sub_node().lod_max_distance * proportion
			e.get_sub_node().lod_min_distance = e.lod_max_distance
		else:
			printd("proportion is strange %s, do nothing" % proportion)
		lodelement_fixchilds(e)
		lodelement_fixchilds(e.get_sub_node())
		
# 		printd("node lod %s %s" % [e.get_sub_node().lod_min_distance, e.get_sub_node().lod_max_distance])
# 		printd("sub  lod %s %s" % [e.lod_min_distance, e.lod_max_distance])

func set_lod_aspect_ratio(value):
	printd("TreeManager update lod_aspect_ratio from %s to %s" % [lod_aspect_ratio, value])
	if value > 0:
		lod_aspect_ratio = value
	if not enabled:
		return
	if enable_hboxsetlod:
		hboxsetlod_set(tree)
		if enable_lodmanager and get_node(LodManager):
			var lm = get_node(LodManager)
			printd("aspect change, Force LodManager to update")
			lm.UpdateLOD(true)

func enable_managment():
	if tree == null:
		printd("TreeManagment faield to enable, tree is not set")
		return false
	printd("TM TreeManagment enable, tree %s" % tree.get_path())
	if enable_hboxsetlod:
		printd("TM start hboxsetlod at %s" % tree.get_path())
		hboxsetlod_set(tree)
	if enable_lodmanager and get_node(LodManager):
		var lm = get_node(LodManager)
		printd("found LodManager at %s" % lm.get_path())
		if enable_hboxsetlod:
			lm.set_scene_path_update(lm.get_path_to(tree), true)
		else:
			lm.set_scene_path_update(lm.get_path_to(tree), true)
		lm.enabled = true
	else:
		printd("LodManager disabled: %s %s" % [enable_lodmanager, LodManager])
		var lm = get_node(LodManager)
		lm.enabled = false
	track_changes(true)
	return true

func disable_managment():
	printd("TreeManagment disable")
	if get_node(LodManager):
		var lm = get_node(LodManager)
		lm.enabled = false
		printd("Disable LodManager %s" % lm.get_path())

	track_changes(false)

func init_tree():
	printd("Init Tree manager")
	if tree == null:
		if get_tree():
			tree = get_tree().current_scene
			printd("tree set to: %s" % tree)
	printd("=tree: %s" % tree)
	if tree:
		printd("Init meshtool and treestats scripts")
		MeshTool = scripts.MeshTool.new(tree)
		TreeStats = scripts.TreeStats.new(tree)

func _ready():
	printd("_ready, enabled(%s)" % enabled)
	if enabled:
		init_tree()
		enable_managment()

func tm_enable(enable):
	printd("Tree manager tm_enable(%s), enabled(%s)" % [enable, enabled])
	if tree == null and enable:
		init_tree()
		if tree == null:
			printd("Tree manager can't set tree, disabled")
			enabled = null
			return
		enabled = false
	if tree == null and not enable:
		if enabled == null:
			disable_managment()
			enabled = false
		return

	if enable :
		if not enabled:
			enabled = enable_managment()
	else:
		if enabled:
			disable_managment()
			enabled = false
