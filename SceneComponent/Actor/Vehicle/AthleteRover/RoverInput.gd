extends AComponent

func _init().("RoverInput", false):
	pass

func _process(_delta: float) -> void:
	handle_input()


func handle_input() -> void:
	entity.input = Vector3.ZERO
	
	entity.input.y = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	
	if Input.is_action_pressed("move_forwards"):
		entity.input.x = 1.0
	
	if Input.is_action_pressed("move_backwards"):
		entity.input.x = -1.0
	
	entity.anim_state = entity.Anim_States.NONE
	
	if Input.is_action_pressed("maneuver_raise"):
		entity.anim_state = entity.Anim_States.RAISE
	
	if Input.is_action_pressed("maneuver_lower"):
		entity.anim_state = entity.Anim_States.LOWER
	
	if Input.is_action_pressed("maneuver_lift_leg"):
		entity.anim_state = entity.Anim_States.LIFT_LEG
