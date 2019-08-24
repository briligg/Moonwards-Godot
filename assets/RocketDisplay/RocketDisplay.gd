extends Spatial

var slide_buttons = []
var info_boxes = []
var current_stage = 1
var max_stages = 5
var transition_duration = 1.0
var transition_timer = transition_duration
var transition_transform_from
var transition_transform_to_object
var return_camera

export(NodePath) var camera_path
onready var camera = get_node(camera_path)

func _ready():
	$Control.visible = false
	$AnimationPlayer.connect("animation_finished", self, "AnimationFinished")
#	yield(get_tree(), "idle_frame")
#	Activate()

func RegisterInfoBox(var node):
	info_boxes.append(node)

func _process(delta):
	if transition_timer < transition_duration:
		transition_timer += delta
		$CameraPivot/CameraPosition/Camera.global_transform = transition_transform_from.interpolate_with(transition_transform_to_object.global_transform, EaseInOutQuad(transition_timer / transition_duration))
		if transition_timer > transition_duration:
			if current_stage == 0 or current_stage == max_stages + 1:
				DeActivate()

func EaseInOutQuad(t):
	return 2*t*t if t<.5 else -1+(4-2*t)*t

func AnimationFinished(var animation_name):
	$CameraPivot.SetEnabled(true)

func Activate():
	$CollisionShape/Display.visible = false
	return_camera = get_tree().root.get_camera()
	camera.global_transform = return_camera.global_transform
	
	camera.current = true
	
	UIManager.request_focus()
	UIManager.free_mouse()
	current_stage = 1
	GoToCurrentStage()
	$Control.visible = true

func DeActivate():
	$CollisionShape/Display.visible = true
	camera.current = false
	current_stage = 0
	$Control.visible = false
	UIManager.release_focus()
	UIManager.lock_mouse()

func StartBladesAnimation():
	$Rocket/RocketBody/ThrustFanBlades_Opt/AnimationPlayer.play("BladesRotate")

func StopBladesAnimation():
	$Rocket/RocketBody/ThrustFanBlades_Opt/AnimationPlayer.stop()

func RegisterSlideButton(var button):
	slide_buttons.append(button)

func NextStage():
	if $AnimationPlayer.is_playing():
		return
	current_stage += 1
	GoToCurrentStage()

func PreviousStage():
	if $AnimationPlayer.is_playing():
		return
	current_stage -= 1
	GoToCurrentStage()

func GoToCurrentStage():
	if current_stage > 0 and current_stage < max_stages + 1:
		if current_stage == 1:
			$Control/VBoxContainer/MainWindow/PreviousButton.text = "Quit"
		else:
			$Control/VBoxContainer/MainWindow/PreviousButton.text = "Previous"
		
		if current_stage == max_stages:
			$Control/VBoxContainer/MainWindow/NextButton.text = "Quit"
		else:
			$Control/VBoxContainer/MainWindow/NextButton.text = "Next"
		
		$AnimationPlayer.play("Stage" + str(current_stage))
	else:
		$AnimationPlayer.play("Stage0")
	
	for info_box in info_boxes:
		info_box.visible = false
	
	GoToCameraStage()

func GoToCameraStage():
	transition_transform_from = camera.global_transform
	
	if current_stage > 0 and current_stage < max_stages + 1:
		transition_transform_to_object = $CameraPivot/CameraPosition
	else:
		transition_transform_to_object = return_camera
	
	transition_timer = 0.0
	
	$CameraPivot.SetEnabled(false)
