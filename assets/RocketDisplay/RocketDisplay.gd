extends Spatial

export(NodePath) var camera_path : NodePath

onready var camera : Node = get_node(camera_path)

const MAX_STAGES : int = 5
const TRANSITION_DURATION : float = 1.0

var current_stage : int = 1
var transition_timer : float = TRANSITION_DURATION
var transition_transform_from : Transform
var transition_transform_to_object : Node
var return_camera : Node

func _ready() -> void:
	$Control.visible = false
	$AnimationPlayer.connect("animation_finished", self, "animation_finished")
#	yield(get_tree(), "idle_frame")
#	activate()

func _process(delta) -> void:
	if transition_timer < TRANSITION_DURATION:
		transition_timer += delta
		$CameraPivot/CameraPosition/Camera.global_transform = transition_transform_from.interpolate_with(transition_transform_to_object.global_transform, ease_in_out_quad(transition_timer / TRANSITION_DURATION))
		if transition_timer > TRANSITION_DURATION:
			if current_stage == 0 or current_stage == MAX_STAGES + 1:
				deactivate()

func ease_in_out_quad(t) -> float:
	return 2*t*t if t<.5 else -1+(4-2*t)*t

func animation_finished(var animation_name) -> void:
	$CameraPivot.set_enabled(true)

func activate() -> void:
	$CollisionShape/Display.visible = false
	return_camera = get_tree().root.get_camera()
	camera.global_transform = return_camera.global_transform

	camera.current = true

	UIManager.request_focus()
	UIManager.free_mouse()
	current_stage = 1
	go_to_current_stage()
	$Control.visible = true

func deactivate() -> void:
	$CollisionShape/Display.visible = true
	camera.current = false
	current_stage = 0
	$Control.visible = false
	UIManager.release_focus()
	UIManager.lock_mouse()

func start_blades_animation() -> void:
	$Rocket/RocketBody/ThrustFanBlades_Opt/AnimationPlayer.play("BladesRotate")

func stop_blades_animation() -> void:
	$Rocket/RocketBody/ThrustFanBlades_Opt/AnimationPlayer.stop()

func next_stage() -> void:
	if $AnimationPlayer.is_playing():
		return
	current_stage += 1
	go_to_current_stage()

func previous_stage() -> void:
	if $AnimationPlayer.is_playing():
		return
	current_stage -= 1
	go_to_current_stage()

func go_to_current_stage() -> void:
	if current_stage > 0 and current_stage < MAX_STAGES + 1:
		if current_stage == 1:
			$Control/VBoxContainer/MainWindow/PreviousButton.text = "Quit"
		else:
			$Control/VBoxContainer/MainWindow/PreviousButton.text = "Previous"

		if current_stage == MAX_STAGES:
			$Control/VBoxContainer/MainWindow/NextButton.text = "Quit"
		else:
			$Control/VBoxContainer/MainWindow/NextButton.text = "Next"

		$AnimationPlayer.play("Stage" + str(current_stage))
	else:
		$AnimationPlayer.play("Stage0")

	go_to_camera_stage()

func go_to_camera_stage() -> void:
	transition_transform_from = camera.global_transform

	if current_stage > 0 and current_stage < MAX_STAGES + 1:
		transition_transform_to_object = $CameraPivot/CameraPosition
	else:
		transition_transform_to_object = return_camera

	transition_timer = 0.0

	$CameraPivot.set_enabled(false)
