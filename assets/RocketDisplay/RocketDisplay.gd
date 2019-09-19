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
onready var billboard : Node = $CollisionShape/Display
onready var camera_pivot : Node = $CameraPivot
onready var camera_position : Node = $CameraPivot/CameraPosition

var _current_stage : int = 1
var _transition_timer : float = TRANSITION_DURATION
var _transition_transform_from : Transform
var _transition_transform_to_object : Node
var _return_camera : Node

func _ready() -> void:
	main_ui.visible = false
	display_animation_player.connect("animation_finished", self, "animation_finished")
#	yield(get_tree(), "idle_frame")
#	activate()

func _process(delta : float) -> void:
	if _transition_timer < TRANSITION_DURATION:
		_transition_timer += delta
		camera.global_transform = _transition_transform_from.interpolate_with(_transition_transform_to_object.global_transform, _ease_in_out_quad(_transition_timer / TRANSITION_DURATION))
		if _transition_timer > TRANSITION_DURATION:
			if _current_stage == 0 or _current_stage == MAX_STAGES + 1:
				deactivate()

func _ease_in_out_quad(t : float) -> float:
	return 2*t*t if t<.5 else -1+(4-2*t)*t

func animation_finished(animation_name : String) -> void:
	camera_pivot.set_enabled(true)

func activate() -> void:
	billboard.visible = false
	_return_camera = get_tree().root.get_camera()
	camera.global_transform = _return_camera.global_transform

	camera.current = true

	UIManager.request_focus()
	UIManager.free_mouse()
	_current_stage = 1
	_go_to__current_stage()
	main_ui.visible = true

func deactivate() -> void:
	billboard.visible = true
	camera.current = false
	_current_stage = 0
	main_ui.visible = false
	UIManager.release_focus()
	UIManager.lock_mouse()

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
