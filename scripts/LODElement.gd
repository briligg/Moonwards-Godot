extends MeshInstance

export (NodePath) var substitute
const id = "LODElement"

var state

func _ready():
	Log.hint(self, "LOD substitute %s of %s" % [get_path(), substitute] )
	if not valid_sub():
		return
# 	fix_spatial()
	add_to_group("LODElement", true)
	set_state()

func set_state():
	if state == null:
		save_state()
	if state == null:
		Log.warning(self, "fail to substitute %s %s %s" % [utils.get_node_file(self), get_path(), substitute])
	var node = get_node(substitute)
	if node.visible:
		node.visible = false
		Log.hint(self, "hide %s" % substitute)
	if not visible:
		visible = true
		Log.hint(self, "show %s" % name)

func save_state():
	if state != null:
		return
	var node = get_node(substitute)
	if node != null:
		state = {
			svisible = node.visible,
			visible = visible
		}

func restore():
	if state:
		var node = get_node(substitute)
		if node:
			if node.visible != state.svisible:
				node.visible = state.svisible
			if visible != state.visible:
				visible = state.visible

func get_sub_node():
	if substitute != "":
		return get_node(substitute)

func valid_sub():
	var node = get_sub_node()
	var valid = true
	if node == null:
		Log.warning(self, "valid_sub, sub not found '%s'" % substitute)
		valid = false
	if node.is_a_parent_of(self):
		Log.warning(self, "valid_sub, substitute node contains %s, %s node %s %s" % [id, get_path(), node.get_path(), utils.get_node_file(self)])
		valid = false
	if is_a_parent_of(node):
		Log.warning(self, "valid_sub, substitute node is child of %s %s node %s %s" % [id, get_path(), node.get_path(), utils.get_node_file(self)])
		valid = false
	return valid

# func fix_spatial():
# 	var node = get_sub_node()
# 	Log.hint(self, "fix spatial %s %s" % [self is Spatial, node is Spatial])
# 	if self is Spatial:
# 		Log.warning(self, "fix_spatial, add min/max to %s %s %s" % [id, get_path(), utils.get_node_file(self)])
# 		self.set("lod_max_distance", 0)
# 		self.set("lod_min_distance", 0)
# 	if node is Spatial:
# 		Log.warning(self, "fix_spatial, add min/max to sub node, %s %s %s" % [id, get_path(), utils.get_node_file(self)])
# 		node.set("lod_max_distance", float(0))
# 		node.set("lod_min_distance", float(0))
# 		Log.warning(self, "fix_spatial, node min/max %s %s" % [node.get("lod_max_distance"), node.get("lod_min_distance")])
# 		Log.warning(self, "fix_spatial, node min/max %s %s" % [node.lod_max_distance, node.lod_min_distance])
# 
