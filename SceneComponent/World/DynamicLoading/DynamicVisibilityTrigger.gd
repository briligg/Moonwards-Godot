extends Area

enum NoListOp {
	Hide,
	ShowLod0,
	ShowLod1,
	ShowLod2,
}

# The operation to perform on nodes not in any of the lists.
export(NoListOp) var orphan_node_op = NoListOp.Hide

export(Array, NodePath) var show_lod0_list
export(Array, NodePath) var show_lod1_list
export(Array, NodePath) var show_lod2_list

export(Array, NodePath) var hide_list

var is_set: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "on_body_entered")
	pass

func on_body_entered(body) -> void:
	if body is AEntity:
		process_visibility()

func process_visibility() -> void:
	if is_set:
		return;
	is_set = true;
	get_tree().call_group(Groups.DYNAMIC_VISIBILITY, "unset")
	
	for node in get_tree().get_nodes_in_group(Groups.LOD_MODELS):
		var path = node.get_path()
		if path in show_lod0_list:
			node.set_lod(0)
		elif path in show_lod1_list:
			node.set_lod(1)
		elif path in show_lod2_list:
			node.set_lod(2)
		else:
			orphan_op(node)

func orphan_op(node):
	match orphan_node_op:
		NoListOp.ShowLod0:
			node.set_lod(0)
		NoListOp.ShowLod1:
			node.set_lod(0)
		NoListOp.ShowLod2:
			node.set_lod(0)
		NoListOp.Hide:
			node.hide_all()

func unset() -> void:
	is_set = false
