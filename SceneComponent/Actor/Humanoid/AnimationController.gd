extends AComponent

enum anim_state {
	ON_GROUND = 0,
	FLAILING = 1,
	CLIMBING = 2
}

var walk_direction = Vector2.ONE
var climb_direction = 1.0

func _init().("AnimationController", false):
	pass

func _ready():
	call_deferred("_initialize")

func _initialize():
	pass

func _process_client(_delta):
	update_animation(_delta)

func _process_server(_delta):
	#If this entity is the the server player entity running on the server then _process_client already updates the animation.
	if not(get_tree().is_network_server() and entity.owner_peer_id == get_tree().get_network_unique_id()):
		update_animation(_delta)

func update_animation(_delta):
	if entity.state.state == ActorEntityState.State.IN_AIR:
		entity.animation_tree.set("parameters/State/current", 1)
	elif entity.state.state == ActorEntityState.State.CLIMBING:
		entity.animation_tree.set("parameters/State/current", 2)
	else:
		entity.animation_tree.set("parameters/State/current", 0)

	if entity.state.state == ActorEntityState.State.CLIMBING:
		update_climb_animation(_delta)
	else:
		update_walk_animation(_delta)

func update_walk_animation(_delta):
	var forward = entity.model.global_transform.basis.z
	var left = entity.model.global_transform.basis.x
	var flat_velocity = Vector3(entity.velocity.x, 0.0, entity.velocity.z)
	
	var forward_amount = forward.dot(flat_velocity)
	var left_amount = left.dot(flat_velocity)
	
	walk_direction = walk_direction.linear_interpolate(Vector2(-left_amount, forward_amount), _delta * 25.0)
	entity.animation_tree.set("parameters/Walking/blend_position", walk_direction)

func update_climb_animation(_delta):
	var kb_pos = entity.global_transform.origin
	var climb_progress
	
	#Determine where we should be setting our feet when climbing.
	if entity.climb_point % 2 == 0:
		climb_progress = abs((2.0 if climb_direction > 0.0 else 0.0) - abs((kb_pos.y - entity.stairs.climb_points[entity.climb_point].y) / entity.stairs.step_size))
	else:
		climb_progress = abs((2.0 if climb_direction > 0.0 else 0.0) - (1.0 + abs(kb_pos.y - entity.stairs.climb_points[entity.climb_point].y) / entity.stairs.step_size))
	
	#Which direction we are traveling in.
	var forward_amount = entity.input.z
	
	#Determine which animation to play if we are at the top of the stairs or still climbing.
	if entity.climb_point == entity.stairs.climb_points.size() - 1 and kb_pos.y > entity.stairs.climb_points[entity.climb_point].y and not forward_amount <= 0.0:
		entity.animation_tree.set("parameters/State/current", anim_state.FLAILING)
	else:
		entity.animation_tree.set("parameters/State/current", anim_state.CLIMBING)
	
	#Change animation if the animation playing is wrong.
	if forward_amount > 0.0:
		if climb_direction == -1.0:
			entity.animation_tree.set("parameters/ClimbDirection/current", 0)
			climb_direction = 1.0
	elif forward_amount < 0.0:
		if climb_direction == 1.0:
			entity.animation_tree.set("parameters/ClimbDirection/current", 1)
			climb_direction = -1.0
	
	entity.animation_tree.set("parameters/ClimbProgressUp/seek_position", climb_progress)
	entity.animation_tree.set("parameters/ClimbProgressDown/seek_position", climb_progress)



