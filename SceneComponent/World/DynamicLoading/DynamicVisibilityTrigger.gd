extends Area

enum NoListOp {
	Hide,
	ShowLod0,
	ShowLod1,
	ShowLod2,
}

export(bool) var pause_on_error: bool = false

# The operation to perform on nodes not in any of the lists.
export(NoListOp) var orphan_node_op = NoListOp.Hide

export(Array, NodePath) var show_lod0_list
export(Array, NodePath) var show_lod1_list
export(Array, NodePath) var show_lod2_list

export(Array, NodePath) var hide_list

var is_set: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(Groups.DYNAMIC_VISIBILITY)
	_validate_paths(show_lod0_list)
	_validate_paths(show_lod1_list)
	_validate_paths(show_lod2_list)
	_validate_paths(hide_list)
	self.connect("body_entered", self, "on_body_entered")
	for n in get_children():
		if n is Area:
			n.connect("body_entered", self, "on_body_entered")

func on_body_entered(body) -> void:
	if VisibilityManager.disable_all_triggers:
		return
		
	if body is AEntity:
		if body.owner_peer_id == get_tree().get_network_unique_id() and VisibilityManager.log_vt_changes:
			Log.trace(self, "on_body_entered", "Processing visibility for %s, in %s"
					%[body.name, self.name])
			process_visibility()

func process_visibility() -> void:
	if is_set:
		return;
	is_set = true;
	get_tree().call_group(Groups.DYNAMIC_VISIBILITY, "unset")
	
	for node in get_tree().get_nodes_in_group(Groups.LOD_MODELS):
		var path = get_path_to(node)
		if path in show_lod0_list:
			node.call_deferred("set_lod", 0)
		elif path in show_lod1_list:
			node.call_deferred("set_lod", 1)
		elif path in show_lod2_list:
			node.call_deferred("set_lod", 2)
		elif path in hide_list:
			node.call_deferred("hide_all")
		else:
			orphan_op(node)

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

func _validate_paths(path_list: Array):
	for path in path_list:
		if get_node(path) == null:
			Log.error(self, "", "DVT Path %s is inavlid in %s." %[path, self.name])
			if pause_on_error:
				assert(false)
