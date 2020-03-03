extends Spatial

onready var label : Node = $MainBody/TourPodArea/CollisionShape/MeshInstance/Viewport/Label
onready var animaton_player : Node = $MainBody/AnimationPlayer
onready var passenger_check : Node = $MainBody/PassengerCheck
onready var body : Node = $MainBody
onready var camera_control : Node = $MainBody/PlayerCamera
onready var camera_target : Node = $MainBody/PlayerCamera/Pivot/CameraTarget
onready var camera : Node = $Camera
onready var target_transform : Transform
onready var _transition_transform_to_object : Node

const TRANSITION_DURATION : float = 1.0

var passengers = []
var ready_to_leave : bool = false
var rover_present : bool = false setget set_rover_present
var timer : float = 0.0
var leave_timeout : float = 5.0
var timer_started : bool = false
var current_location = 0
var locations = []
var next_docking_node = null
var _transition_timer : float = TRANSITION_DURATION
var _transition_transform_from : Transform
var _return_camera : Node
var _transition_camera = false

signal _camera_transition_done

func _ready() -> void:
	_set_target_location()

func _set_target_location() -> void:
	if current_location >= locations.size():
		current_location = 0
	next_docking_node = locations[current_location]
	target_transform = next_docking_node.global_transform

func set_rover_present(var _rover_present) -> void:
	rover_present = _rover_present
	if rover_present:
		_set_text("Press E\nto start tour.")
	else:
		_set_text("Waiting\nfor rover...")

func _process(delta : float) -> void:
	if _transition_timer < TRANSITION_DURATION:
		_transition_timer += delta
		camera.global_transform = _transition_transform_from.interpolate_with(_transition_transform_to_object.global_transform, _ease_in_out_quad(_transition_timer / TRANSITION_DURATION))
		if _transition_timer >= TRANSITION_DURATION:
			_transition_timer = TRANSITION_DURATION
			emit_signal("_camera_transition_done")
	elif timer_started:
		timer += delta
		_set_text("Leaving in \n" + str(round(leave_timeout - timer)) + "\n seconds.")
		if timer >= (leave_timeout - 1.0):
			timer_started = false
			animaton_player.play("CloseDoor")
			_set_text("")
			yield(animaton_player, "animation_finished")
			_lock_passengers()
			_camera_transition_check()
			if _transition_camera:
				yield(self, "_camera_transition_done")
			body.set_collision_layer_bit(1, false)
			ready_to_leave = true
			timer = 0.0

func _camera_transition_check() -> void:
	if _transition_camera:
		_return_camera = get_tree().root.get_camera()
		_transition_transform_to_object = camera_target
		_transition_transform_from = _return_camera.global_transform
		camera_control.set_camera_control(true)
		_transition_timer = 0.0

func _ease_in_out_quad(t : float) -> float:
	return 2*t*t if t<.5 else -1+(4-2*t)*t

func activate() -> void:
	if rover_present:
		timer_started = true

func _set_text(text : String) -> void:
	label.text = text

func _lock_passengers():
	var space_state = get_world().get_direct_space_state()
	var query = PhysicsShapeQueryParameters.new()
	query.set_collision_mask(8)
	query.set_shape(passenger_check.shape)
	query.transform = passenger_check.global_transform
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var object = result.collider
		if object is KinematicBody:
			var parent = object.get_parent()
			passengers.append({"object" : object, "parent" : parent})
			parent.frozen = true
			var old_transform = object.global_transform
			parent.remove_child(object)
			body.add_child(object)
			object.global_transform = old_transform
			if !parent.puppet:
				_transition_camera = true

func free_passengers() -> void:
	for passenger in passengers:
		var old_transform = passenger.object.global_transform
		body.remove_child(passenger.object)
		passenger.parent.add_child(passenger.object)
		passenger.object.global_transform = old_transform
		passenger.parent.frozen = false
	passengers.resize(0)

func delivered() -> void:
	ready_to_leave = false
	
	_transition_transform_from = camera.global_transform
	_transition_transform_to_object = _return_camera
	
	_transition_timer = 0.0
	yield(self, "_camera_transition_done")
	body.set_collision_layer_bit(1, true)
	free_passengers()
	camera_control.set_camera_control(false)
	animaton_player.play("OpenDoor")
	current_location += 1
	_set_target_location()
