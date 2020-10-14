extends Reference
class_name AnchorMovementData

var entity
# The actual game object that we're anchored to
var anchor_node: Node setget ,get_anchor_node
# The generated position node to anchor ourselves to
onready var anchor_pos3d_node: Position3D 
# Position of the anchor_node, typically used as the position to place the anchored entity
#var anchor_position: Vector3 setget , get_anchor_position

var is_anchored: bool = false setget set_is_anchored, get_is_anchored

func _init(_entity):
	entity = _entity
	anchor_pos3d_node = Position3D.new()
	entity.add_child(anchor_pos3d_node)
	anchor_pos3d_node.owner = entity
	anchor_pos3d_node.global_transform.origin = entity.global_transform.origin

func attach(node: Node):
	anchor_node = node
	Helpers.call_deferred("reparent", anchor_pos3d_node, anchor_node, true)
	self.is_anchored = true

func detach():
	anchor_node = null
	Helpers.call_deferred("reparent", anchor_pos3d_node, entity, true)
	self.is_anchored = false

func get_anchor_node() -> Node:
	return anchor_node

func get_anchor_position() -> Vector3:
	return anchor_pos3d_node.global_transform.origin

func set_is_anchored(val: bool):
	is_anchored = val
	
func get_is_anchored() -> bool:
	return is_anchored and anchor_node != null and anchor_pos3d_node != null
