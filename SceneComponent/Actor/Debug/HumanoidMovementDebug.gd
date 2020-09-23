extends AComponent
class_name HumanoidMovementDebug

var is_flying: bool = false
var movement_input: Vector3 = Vector3()
export(float) var speed = 6
var speed_multiplier = 1

func _init().("HumanoidMovementDebug", true):
	pass

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	_check_flight_mode()
	if !is_flying:
		return
	_handle_input()
	_rotate_body()
	_update_movement(_delta)

func _check_flight_mode():
	#Fly upwards if the player requested it.
	if ProjectSettings.get("debug/settings/gameplay/humans_can_fly"):
		#Start flying if the player requested it.
		if Input.is_action_just_pressed("toggle_fly"):
			_toggle_fly()

func _handle_input() -> void:
	if Input.is_action_pressed("fly_up") :
		movement_input.y = 1
	elif Input.is_action_pressed("fly_down") :
		movement_input.y = -1
	else:
		movement_input.y = 0
	if Input.is_action_pressed("move_forwards"):
		movement_input.z = 1
	elif Input.is_action_pressed("move_backwards"):
		movement_input.z = -1
	else:
		movement_input.z = 0
	if Input.is_action_pressed("move_left"):
		movement_input.x = 1
	elif Input.is_action_pressed("move_right"):
		movement_input.x = -1
	else:
		movement_input.x = 0

func _toggle_fly() -> void :
	is_flying = !is_flying
	
	#SHut off collision detection for the entity.
	entity.set_collision_mask_bit(0, !is_flying)
	entity.set_collision_layer_bit(0, !is_flying)
	entity.mode = RigidBody.MODE_KINEMATIC
	entity.get_component("AMovementController").disable()

func _rotate_body() -> void:
	# Rotate
	var o = entity.global_transform.origin
	var t = entity.look_dir
	var theta = atan2(o.x - t.x, o.z - t.z)
	entity.model.set_rotation(Vector3(0, theta, 0))

func _update_movement(delta):
	var mov = movement_input.z * entity.model.transform.basis.z
	mov += movement_input.x * entity.model.transform.basis.x
	mov.y = movement_input.y
	entity.global_transform.origin += mov * delta * speed * speed_multiplier
