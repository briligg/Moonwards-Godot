extends AComponent
class_name InputController

var ignore_inputs : bool = false

func _init().("InputController", true):
	pass

func _ready():
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING, self, "set_ignore_inputs", [true])
	Signals.Hud.connect(Signals.Hud.CHAT_FINISHED_TYPING, self, "set_ignore_inputs", [false])
	
func _process_client(_delta):
	entity.input = Vector3.ZERO
	handle_input()

func handle_input() -> void:
	if ignore_inputs :
		return
	
	if Input.is_action_pressed("jump"):
		entity.input.y += 1
		
	if Input.is_action_pressed("move_forwards"):
		entity.input += entity.transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		entity.input += -entity.transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		entity.input += entity.transform.basis.x
	elif Input.is_action_pressed("move_right"):
		entity.input += -entity.transform.basis.x 

func set_ignore_inputs(ignore_bool : bool) -> void :
	ignore_inputs = ignore_bool




