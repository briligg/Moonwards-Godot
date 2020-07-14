extends AComponent

var walk_direction = Vector2.ONE

func _init().("AnimationController", false):
	pass

func _ready() -> void:
	call_deferred("_initialize")

func _initialize() -> void:
	pass

func _process_client(_delta: float) -> void:
	update_walk_animation(_delta)

func _process_server(_delta: float) -> void:
	#If this entity is the the server player entity running on the server then _process_client already updates the animation.
	if not(get_tree().is_network_server() and entity.owner_peer_id == get_tree().get_network_unique_id()):
		update_walk_animation(_delta)

func update_walk_animation(_delta):
	if entity.state.changed:
		if entity.state.state == ActorEntityState.State.IN_AIR:
			entity.animation_tree.set("parameters/State/current", 1)
		else:
			entity.animation_tree.set("parameters/State/current", 0)
	
	
	var forward = entity.model.global_transform.basis.z
	var left = entity.model.global_transform.basis.x
	var flat_velocity = Vector3(entity.velocity.x, 0.0, entity.velocity.z)
	
	var forward_amount = forward.dot(flat_velocity)
	var left_amount = left.dot(flat_velocity)
	
	walk_direction = walk_direction.linear_interpolate(Vector2(-left_amount, forward_amount), _delta * 15.0)
	entity.animation_tree.set("parameters/Walking/blend_position", walk_direction)
