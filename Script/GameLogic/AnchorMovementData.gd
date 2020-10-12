extends Reference
class_name AnchorMovementData

var entity
# The node to anchor ourselves to
var anchor_node: Node setget set_anchor_node, get_anchor_node
# The position delta between anchor & entity at the moment of anchoring
var origin_pos_delta: Vector3 = Vector3()
# Position of the anchor node in the tick that was just processed
var last_tick_pos: Vector3 = Vector3()
# Movement delta of the anchor node
var movement_delta: Vector3 = Vector3()
# Whether we're anchored or moving freely
var is_anchored: bool = false setget set_is_anchored, get_is_anchored

func _init(_entity):
	entity = _entity

func _ready():
	if anchor_node != null:
		last_tick_pos = anchor_node.global_transform.origin

func _physics_process(_delta):
	if anchor_node == null:
		return
	movement_delta = anchor_node.global_transform.origin - last_tick_pos
	last_tick_pos = anchor_node.global_transform.origin

func set_anchor_node(node: Node):
	if node != null:
		anchor_node = node
		last_tick_pos = anchor_node.global_transform.origin
		origin_pos_delta = anchor_node.global_transform.origin - entity.global_transform.origin

func get_anchor_node() -> Node:
	return anchor_node

func set_is_anchored(val: bool):
	is_anchored = val
	
func get_is_anchored() -> bool:
	return is_anchored and anchor_node != null
