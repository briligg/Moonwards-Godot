extends Reference
class_name AnchorMovementData

var entity
# The node to anchor ourselves to
var anchor_node: Node setget set_anchor_node, get_anchor_node
# Position of the anchor_node, typically used as the position to place the anchored entity
var anchor_position: Vector3 setget , get_anchor_position

var is_anchored: bool = false setget set_is_anchored, get_is_anchored

func _init(_entity):
	entity = _entity

func set_anchor_node(node: Node):
	if node != null:
		# Cleanup - dispose of the old anchor node
		if anchor_node != null:
			anchor_node.queue_free()
			anchor_node = null

		var anc_pos3d = Position3D.new()
		node.add_child(anc_pos3d)
		anc_pos3d.owner = node
		anc_pos3d.global_transform.origin = entity.global_transform.origin
		anchor_node = anc_pos3d
	# Cleanup when resetting the anchor
	elif node == null and anchor_node != null:
		anchor_node.queue_free()

func get_anchor_node() -> Node:
	return anchor_node

func get_anchor_position() -> Vector3:
	return anchor_node.global_transform.origin

func set_is_anchored(val: bool):
	is_anchored = val
	
func get_is_anchored() -> bool:
	return is_anchored and anchor_node != null
