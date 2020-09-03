extends Spatial

export(NodePath) var camera_path : NodePath

const MAX_STAGES : int = 5
const TRANSITION_DURATION : float = 1.0

onready var camera : Node = get_node(camera_path)
onready var main_ui : Node = $Control
onready var display_animation_player : Node = $AnimationPlayer
onready var rocket_animation_player : Node = $Rocket/RocketBody/ThrustFanBlades_Opt/AnimationPlayer
onready var previous_button : Node = $Control/VBoxContainer/MainWindow/PreviousButton
onready var next_button : Node = $Control/VBoxContainer/MainWindow/NextButton
onready var camera_pivot : Node = $CameraPivot
onready var camera_position : Node = $CameraPivot/CameraPosition

var _current_stage : int = 1
var _transition_timer : float = TRANSITION_DURATION
var _transition_transform_from : Transform
var _transition_transform_to_object : Node
var _return_camera : Node
var _interactor : Node


func _ready() -> void:
	set_process_input(false)
	main_ui.visible = false
	display_animation_player.connect("animation_finished", self, "animation_finished")


func _process(delta : float) -> void:
	if _transition_timer < TRANSITION_DURATION:
		_transition_timer += delta
		camera.global_transform = _transition_transform_from.interpolate_with(_transition_transform_to_object.global_transform, _ease_in_out_quad(_transition_timer / TRANSITION_DURATION))
		if _transition_timer > TRANSITION_DURATION:
			if _current_stage == 0 or _current_stage == MAX_STAGES + 1:
				deactivate()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		if main_ui.visible:
			main_ui.visible = false
		else:
			main_ui.visible = true
	if event.is_action_pressed("ui_left"):
		if main_ui.visible:
			previous_stage()
	if event.is_action_pressed("ui_right"):
		if main_ui.visible:
			next_stage()


func _ease_in_out_quad(t : float) -> float:
	return 2*t*t if t<.5 else -1+(4-2*t)*t


func animation_finished(_animation_name : String) -> void:
	previous_button.disabled = false
	next_button.disabled = false
	camera_pivot.set_enabled(true)


func activate() -> void:
	_interactor.disable()
	
	set_process_input(true)
	main_ui.visible = false
	
	_return_camera = get_tree().root.get_camera()
	camera.global_transform = _return_camera.global_transform

	camera.current = true
	
	_current_stage = 1
	_go_to__current_stage()


func deactivate() -> void:
	_interactor.enable()
	
	set_process_input(false)
	
	camera.current = false
	_current_stage = 0
	
	main_ui.visible = false
	previous_button.disabled = false
	next_button.disabled = false


func start_blades_animation() -> void:
	rocket_animation_player.play("BladesRotate")


func stop_blades_animation() -> void:
	rocket_animation_player.stop()


func next_stage() -> void:
	if display_animation_player.is_playing():
		return
	_current_stage += 1
	_go_to__current_stage()


func previous_stage() -> void:
	if display_animation_player.is_playing():
		return
	_current_stage -= 1
	_go_to__current_stage()


func _go_to__current_stage() -> void:
	if range(1, MAX_STAGES + 1).has(_current_stage):
		if _current_stage == 1:
			previous_button.text = "Quit"
		else:
			previous_button.text = "Previous"

		if _current_stage == MAX_STAGES:
			next_button.text = "Quit"
		else:
			next_button.text = "Next"

		previous_button.disabled = true
		next_button.disabled = true
		
		display_animation_player.play("Stage" + str(_current_stage))
	else:
		display_animation_player.play("Stage0")

	_go_to_camera_stage()


func _go_to_camera_stage() -> void:
	_transition_transform_from = camera.global_transform

	if range(1, MAX_STAGES + 1).has(_current_stage):
		_transition_transform_to_object = camera_position
	else:
		_transition_transform_to_object = _return_camera

	_transition_timer = 0.0

	camera_pivot.set_enabled(false)


func _on_Interactable_interacted_by(interactor: Node):
	self._interactor = interactor
	yield(get_tree(), "idle_frame")
	activate()
