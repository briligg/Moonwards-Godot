extends AComponent

signal jump_pressed

func _init().("RoverInput", true):
	self.enabled = false

func _process_client(_delta: float) -> void:
	handle_input()

func handle_input() -> void:
	if MwInput.is_chat_active:
		return
	
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
	
	if Input.is_action_just_pressed("jump"):
		# This will be true only on the frame that the user pressed down the button, since we want to apply only
		# one impulse; To avoid having "movement" code here, we emit a signal: signals are reliable for 1-frame stuff,
		# as opposed to using the Anim_States which might not be recognized in a diff script in 1 frame
		rpc_id(1, "jump")

mastersync func jump():
	emit_signal("jump_pressed")
