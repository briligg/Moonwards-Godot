extends AComponent

var ignore_inputs : bool = false

func _init().("RoverInput", true):
	pass

func _ready():
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_STARTED, self, 
			"set_ignore_inputs", [true])
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_FINISHED, self, 
			"set_ignore_inputs", [false])
	
#func _process_client(_delta):
func _process(_delta):
	entity.input = Vector3.ZERO
	handle_input()

func handle_input() -> void:
	if ignore_inputs :
		return
	
	if Input.is_action_pressed("jump"):
		entity.input.y = 1
	elif Input.is_action_just_released("jump"):
		entity.input.y = 0

	if Input.is_action_pressed("move_forwards"):
		entity.input.z = 1
	elif Input.is_action_pressed("move_backwards"):
		entity.input.z = -1
	else:
		entity.input.z = 0
	
	if Input.is_action_pressed("move_left"):
		entity.input.x += 1
	elif Input.is_action_pressed("move_right"):
		entity.input.x = -1
	else:
		entity.input.x = 0

func set_ignore_inputs(val : bool) -> void :
	ignore_inputs = val
