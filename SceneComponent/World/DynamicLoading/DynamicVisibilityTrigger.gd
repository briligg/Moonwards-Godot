extends Area
class_name DynamicVisibilityTrigger

enum NoListOp {
	Hide,
	ShowLod0,
	ShowLod1,
	ShowLod2,
}

# The operation to perform on nodes not in any of the lists.
export(NoListOp) var orphan_node_op = NoListOp.Hide

# LOD lists
export(Array, NodePath) var show_lod0_list
export(Array, NodePath) var show_lod1_list
export(Array, NodePath) var show_lod2_list
export(Array, NodePath) var hide_list

# For non-LOD nodes, these will hide/show normal nodes.
export(Array, NodePath) var force_hide_list
export(Array, NodePath) var force_show_list

var is_set: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(Groups.DYNAMIC_VISIBILITY)
	_validate_paths(show_lod0_list)
	_validate_paths(show_lod1_list)
	_validate_paths(show_lod2_list)
	_validate_paths(hide_list)
	_validate_paths(force_hide_list)
	_validate_paths(force_show_list)
	
	yield(Signals.Loading, Signals.Loading.WORLD_POST_READY)
	
	self.connect("body_entered", self, "on_body_entered")
	for n in get_children():
		if n is Area:
			n.connect("body_entered", self, "on_body_entered")

func on_body_entered(body) -> void:
	if VisibilityManager.disable_all_triggers:
		return
		
	if body is AEntity:
		if body.owner_peer_id == get_tree().get_network_unique_id():
			process_visibility()
			if VisibilityManager.log_vt_changes:
				Log.trace(self, "on_body_entered", "Processing visibility for %s, in %s"
						%[body.name, self.name])

func process_visibility() -> void:
	if is_set:
		return;
	is_set = true;
	
	var dvts = get_tree().get_nodes_in_group(Groups.DYNAMIC_VISIBILITY)
	# Remove ourselves to loop over only the other DVTs
	dvts.erase(self)
	for node in dvts:
		node.call_deferred("unset")
		if !is_set:
			return
	# This could use some optimization
	for path in show_lod0_list:
		var node = get_node(path)
		_process_visibility_recursive(node, path, VisibilityManager.LodState.LOD0)
	for path in show_lod1_list:
		var node = get_node(path)
		_process_visibility_recursive(node, path, VisibilityManager.LodState.LOD1)
	for path in show_lod2_list:
		var node = get_node(path)
		_process_visibility_recursive(node, path, VisibilityManager.LodState.LOD2)
	for path in hide_list:
		var node = get_node(path)
		_process_visibility_recursive(node, path, VisibilityManager.LodState.HIDDEN)

	# Code below can be better restructured
	for path in force_hide_list:
		var node = get_node_or_null(path)
		if node != null:
			node.visible = false
			VisibilityManager.update_context(node)
		else:
			Log.error(self, "process_visibility", "Node does not exist: %s" %path)
	for path in force_show_list:
		var node = get_node_or_null(path)
		if node != null:
			node.visible = true
			VisibilityManager.update_context(node)
		else:
			Log.error(self, "process_visibility", "Node does not exist: %s" %path)

func orphan_op(node):
	match orphan_node_op:
		NoListOp.ShowLod0:
			node.call_deferred("set_lod", 0)
		NoListOp.ShowLod1:
			node.call_deferred("set_lod", 1)
		NoListOp.ShowLod2:
			node.call_deferred("set_lod", 2)
		NoListOp.Hide:
			node.call_deferred("hide_all")

func unset() -> void:
	is_set = false

func _process_visibility_recursive(node, path, lod_level):
	# To account for nodes that were possibly removed or reparented at runtime
	if node == null:
		Log.error(self, "_process_visibility_recursive", 
				"Entry %s yielded a null value when converted to node." %path)
		return

	if node is LodModel:
		node.call_deferred("set_lod", lod_level)
		
	var children = node.get_children()
	if children.empty():
		return
		
	for child in children:
		if child is LodModel:
			child.call_deferred("set_lod", lod_level)
		if child:
			_process_visibility_recursive(child, child.get_path(), lod_level)

func _validate_paths(path_list: Array):
	for path in path_list:
		if get_node(path) == null:
			Log.error(self, "", "DVT Path %s is inavlid in %s." %[path, self.name])
			path_list.erase(path)
			if VisibilityManager.pause_on_error:
				assert(false)
