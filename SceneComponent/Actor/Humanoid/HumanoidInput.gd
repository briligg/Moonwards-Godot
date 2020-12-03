extends AComponent
class_name InputController

var ignore_inputs : bool = false

func _init().("HumanoidInput", true):
	pass

func _ready() -> void:
	Input.set_use_accumulated_input(false)
	Signals.Entities.connect(Signals.Entities.FREE_CAMERA_SET, self, "set_ignore_inputs")
	
func _process_client(_delta: float) -> void:
	entity.input = Vector3.ZERO
	handle_input()

func handle_input() -> void:
	if ignore_inputs or MwInput.is_chat_active:
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
	
	get_tree().set_input_as_handled()
	
func set_ignore_inputs(ignore_bool : bool) -> void :
	ignore_inputs = ignore_bool
