extends Spatial

onready var label : Node = $MainBody/TourPodArea/CollisionShape/MeshInstance/Viewport/Label
onready var animaton_player : Node = $MainBody/AnimationPlayer
onready var passenger_check : Node = $MainBody/PassengerCheck
onready var body : Node = $MainBody
onready var camera_control : Node = $MainBody/PlayerCamera
export(Array, NodePath) var location_paths

var passengers = []
var ready_to_leave : bool = false
var rover_present : bool = false setget set_rover_present
var timer : float = 0.0
var leave_timeout : float = 5.0
var timer_started : bool = false
var current_location = 0
var locations = []
onready var target_transform : Transform

func _ready():
	for location_path in location_paths:
		locations.append(get_node(location_path))
	_set_target_location()

func _set_target_location():
	if current_location >= locations.size():
		current_location = 0
	target_transform = locations[current_location].global_transform

func set_rover_present(var _rover_present):
	rover_present = _rover_present
	if rover_present:
		_set_text("Press E\nto start tour.")
	else:
		_set_text("Waiting\nfor rover...")

func _process(delta):
	if timer_started:
		timer += delta
		_set_text("Leaving in \n" + str(round(leave_timeout - timer)) + "\n seconds.")
		if timer >= (leave_timeout - 1.0):
			timer_started = false
			animaton_player.play("CloseDoor")
			_set_text("")
			yield(animaton_player, "animation_finished")
			_lock_passengers()
			body.set_collision_layer_bit(1, false)
			ready_to_leave = true
			timer = 0.0

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
				camera_control.set_camera_control(true)

func free_passengers():
	for passenger in passengers:
		var old_transform = passenger.object.global_transform
		body.remove_child(passenger.object)
		passenger.parent.add_child(passenger.object)
		passenger.object.global_transform = old_transform
		passenger.parent.frozen = false
	passengers.resize(0)

func delivered():
	ready_to_leave = false
	body.set_collision_layer_bit(1, true)
	free_passengers()
	camera_control.set_camera_control(false)
	animaton_player.play("OpenDoor")
	current_location += 1
	_set_target_location()
