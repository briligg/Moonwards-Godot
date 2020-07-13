extends AComponent

# Control properties
export var engine_power: float = 4000.0 # At most 6x the weight
export var max_steering_angle: float = 40.0 # Wheel steering angle
export var steering_speed: float = 2.0 # How fast the wheel turns
export var power_per_wheel: float # Set in _ready

func _init().("RoverMovement", false):
	pass

func _ready() -> void:
	# Distribute power equally amongst the powered wheels
	power_per_wheel = engine_power / 6.0 # This is still recommended to have as 6 (6 wheels) even as 4WD

func _physics_process(delta: float) -> void:
	var front_target: float = entity.input.y * max_steering_angle
	var back_target: float = entity.input.y * -max_steering_angle
	
	# In order: LF, RF, LB, RB
	entity.wheels[0].rotation_degrees.y = lerp(entity.wheels[0].rotation_degrees.y, front_target, 
		(1.0 - exp(-steering_speed * delta)))
	entity.wheels[3].rotation_degrees.y = lerp(entity.wheels[3].rotation_degrees.y, front_target, 
		(1.0 - exp(-steering_speed * delta)))
	entity.wheels[2].rotation_degrees.y = lerp(entity.wheels[2].rotation_degrees.y, back_target, 
		(1.0 - exp(-steering_speed * delta)))
	entity.wheels[5].rotation_degrees.y = lerp(entity.wheels[5].rotation_degrees.y, back_target, 
		(1.0 - exp(-steering_speed * delta)))
	
	# 4 wheel drive, middle wheels do not exert engine force - can be changed, but works well
	entity.wheels[0].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel * delta)
	entity.wheels[3].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel * delta)
	entity.wheels[2].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel * delta)
	entity.wheels[5].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel * delta)
