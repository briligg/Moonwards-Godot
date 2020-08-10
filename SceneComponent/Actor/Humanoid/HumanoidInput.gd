extends AComponent
class_name InputController

var ignore_inputs : bool = false

func _init().("HumanoidInput", true):
	pass

func _ready() -> void:
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_STARTED, self, "set_ignore_inputs", [true])
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_FINISHED, self, "set_ignore_inputs", [false])
	
func _process_client(_delta: float) -> void:
	entity.input = Vector3.ZERO
	entity.fly_input_float = 0
	handle_input()

func handle_input() -> void:
	if ignore_inputs :
		return
	
	if Input.is_action_pressed("jump"):
		entity.input.y += 1
		
	if Input.is_action_pressed("move_forwards"):
		entity.input.z += 1
	elif Input.is_action_pressed("move_backwards"):
		entity.input.z += -1
		
	if Input.is_action_pressed("move_left"):
		entity.input.x += 1
	elif Input.is_action_pressed("move_right"):
		entity.input.x += -1
	
	#Start flying if the player requested it.
	if Input.is_action_just_pressed("toggle_fly"):
		Signals.Entities.emit_signal(Signals.Entities.FLY_TOGGLED)
	
	#Fly upwards if the player requested it.
	if Input.is_action_pressed("fly_up") :
		entity.fly_input_float += 1
	elif Input.is_action_pressed("fly_down") :
		entity.fly_input_float -= 1

func set_ignore_inputs(ignore_bool : bool) -> void :
	ignore_inputs = ignore_bool
