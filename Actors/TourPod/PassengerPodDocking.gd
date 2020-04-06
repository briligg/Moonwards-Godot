tool
extends Spatial

var tour_pod_resource : Resource = preload("res://Actors/TourPod/TourPod.tscn")
onready var airlock_animation_player : AnimationPlayer = get_node("Airlock/AnimationPlayer")
export(bool) var occupied : bool = false setget _set_preview_pod
var tour_pod : Node = null
export(Array, NodePath) var location_paths
var _state = AIRLOCK_STATE.BOTH_CLOSED
var _timer : float = 0.0
var _timer_started : bool = false
const _timeout_duration : float = 2.0

enum AIRLOCK_STATE {
	INSIDE_OPEN,
	OUTSIDE_OPEN,
	BOTH_CLOSED_GOING_OUTSIDE,
	BOTH_CLOSED_GOING_INSIDE,
	BOTH_CLOSED
}

func _ready() -> void:
	if !Engine.editor_hint:
		if occupied:
			_state = AIRLOCK_STATE.INSIDE_OPEN
			airlock_animation_player.play("InsideDoorOpen")
			tour_pod = tour_pod_resource.instance()
			var locations = []
			for location_path in location_paths:
				locations.append(get_node(location_path))
			
			tour_pod.locations = locations
			add_child(tour_pod)
		else:
			airlock_animation_player.play("InsideDoorClose")
		$PassengerPodPlaceholder.queue_free()
		$Ground_Passenger_Pod.queue_free()

func _set_preview_pod(var _occupied : bool):
	occupied = _occupied
	if Engine.editor_hint:
		$PassengerPodPlaceholder.visible = !occupied
		$Ground_Passenger_Pod.visible = occupied

func passenger_pod_leave():
	occupied = false
	if _state == AIRLOCK_STATE.OUTSIDE_OPEN:
		airlock_animation_player.play("OutsideDoorClose")

func passenger_pod_arrive():
	occupied = true
	if _state == AIRLOCK_STATE.INSIDE_OPEN:
		_timer_started = true
	else:
		airlock_animation_player.play("OutsideDoorOpen")
		_state = AIRLOCK_STATE.OUTSIDE_OPEN

func _process(delta):
	if _timer_started:
		_timer += delta
		if _timer >= _timeout_duration:
			_timer = 0.0
			_update_airlock_state()

func _update_airlock_state():
	if _state == AIRLOCK_STATE.INSIDE_OPEN:
		_state = AIRLOCK_STATE.BOTH_CLOSED_GOING_OUTSIDE
		airlock_animation_player.play("InsideDoorClose")
	elif _state == AIRLOCK_STATE.BOTH_CLOSED_GOING_OUTSIDE:
		_state = AIRLOCK_STATE.OUTSIDE_OPEN
		airlock_animation_player.play("OutsideDoorOpen")
		_timer_started = false
	elif _state == AIRLOCK_STATE.OUTSIDE_OPEN:
		_state = AIRLOCK_STATE.BOTH_CLOSED_GOING_INSIDE
		airlock_animation_player.play("OutsideDoorClose")
	elif _state == AIRLOCK_STATE.BOTH_CLOSED_GOING_INSIDE:
		_state = AIRLOCK_STATE.INSIDE_OPEN
		airlock_animation_player.play("InsideDoorOpen")
		_timer_started = false

func _passenger_entered(body):
	if !_timer_started and occupied and (_state == AIRLOCK_STATE.OUTSIDE_OPEN or _state == AIRLOCK_STATE.INSIDE_OPEN):
		_timer_started = true
