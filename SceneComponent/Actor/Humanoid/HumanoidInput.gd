extends AComponent
class_name InputController

onready var input : InputEPI = entity.demand_epi(EPIManager.INPUT_EPI)
onready var switch_context : SwitchContextEPI = entity.request_epi(EPIManager.SWITCH_CONTEXT_EPI)

var ignore_inputs : bool = false

func _init().("HumanoidInput", true):
	pass

func _ready() -> void:
	Signals.Entities.connect(Signals.Entities.FREE_CAMERA_SET, self, "set_ignore_inputs")
	
	#Start accepting input when context is given.
	switch_context.connect(switch_context.CONTEXT_TAKEN, self, "enable")
	switch_context.connect(switch_context.CONTEXT_LOST, self, "disable")

func _process_client(_delta: float) -> void:
	entity.input = Vector3.ZERO
	input.input = Vector3.ZERO
	handle_input()

func handle_input() -> void:
	if ignore_inputs or MwInput.is_chat_active:
		return
	
	if Input.is_action_pressed("jump"):
		input.jump(1)
	
	input.input.z = -Input.get_action_strength("move_backwards") + Input.get_action_strength("move_forwards")
	input.input.x = -Input.get_action_strength("move_right") + Input.get_action_strength("move_left")

func set_ignore_inputs(ignore_bool : bool) -> void :
	ignore_inputs = ignore_bool
