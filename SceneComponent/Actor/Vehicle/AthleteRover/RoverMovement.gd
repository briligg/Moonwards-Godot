extends AComponent

# Control properties
export var engine_power: float = 11000.0 # At most 6x the weight
export var max_steering_angle: float = 15.0 # Wheel steering angle
export var steering_speed: float = 2.0 # How fast the wheel turns
export var power_per_wheel: float # Set in _ready

# Jump properties
# We want to prevent successive jumps because muscles/hydraulics aren't instant, so time has to be given for them
# to actuate before allowing another jump attempt
var _jump_timer: float = 0.0
var jump_cooldown: float = 2.0
# Main body center of mass, currently matches the rootcol pos
var m_b_center_mass: Vector3 = Vector3(0.0, 0, 0.0)  
# Collision mask to determine how close the center of mass is from the ground - should only want the ground, so any
# load/cargo below the body should be in a different layer
var coll_mask: int = 1
var jump_col_ignore = [entity]
var jump_min_distance: float = 3.5 # What to consider as minimum distance for jump_max_force
var jump_max_distance: float = 13.5 # What to consider as maximum distance for jump_min_force
var jump_min_force: float = 105.0 # Force per wheel -> when jumping with body at highest point
var jump_max_force: float = 160.0 # Force per wheel -> when jumping with body at lowest point

func _init().("RoverMovement", false):
	pass

func _ready() -> void:
	# Distribute power equally amongst the powered wheels
	power_per_wheel = engine_power / 6.0 # This is still recommended to have as 6 (6 wheels) even as 4WD

func _process_server(delta: float) -> void:
	# Decrease jump cooldown
	if (_jump_timer > 0.0):
		_jump_timer = max(_jump_timer - delta, 0.0)
	
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
	entity.wheels[0].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel)# * delta)
	entity.wheels[3].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel)# * delta)
	entity.wheels[2].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel / 1.5)# * delta)
	entity.wheels[5].apply_engine_force(entity.input.x * entity.global_transform.basis.z * power_per_wheel / 1.5)# * delta)
	entity.srv_pos = entity.global_transform.origin
	entity.srv_basis = entity.global_transform.basis

func _process_client(_delta: float) -> void:
	if !is_network_master():
		var p = entity.srv_pos
		var b = entity.srv_basis
		entity.global_transform.origin = p
		entity.global_transform.basis = b

func on_jump_pressed() -> void:
	if (_jump_timer > 0.0):
		return # Jump still on cooldown
	_jump_timer = jump_cooldown
	
	# Find distance from ground to scale jump force accordingly
	var _dist: float = jump_max_distance
	
	var _from: Vector3 = entity.global_transform.origin + entity.global_transform.basis.y * m_b_center_mass
	var _to: Vector3 = entity.global_transform.origin + entity.global_transform.basis.y * Vector3(0.0, -12.0, 0.0)
	
	var _d_s_s: PhysicsDirectSpaceState = entity.get_world().direct_space_state
	var _res: Dictionary = _d_s_s.intersect_ray(_from, _to, jump_col_ignore, coll_mask)
	
	DebugDraw.c_draw_line(_from, _to, Color(255,0,0), jump_cooldown)
	if _res:
		_dist = _from.distance_to(_res.position)
	
	# Scale a range [min,max] to [a,b] -> ( (b-a)*(x - min) / (max - min) ) + a
	var _force_x: float = ( (jump_max_force - jump_min_force)*(_dist - jump_max_distance) / 
		(jump_min_distance - jump_max_distance) ) + jump_min_force
	
	# All legs will exert a force upwards
	entity.wheels[0].apply_jump_force(entity.global_transform.basis.y * _force_x)
	entity.wheels[1].apply_jump_force(entity.global_transform.basis.y * _force_x)
	entity.wheels[2].apply_jump_force(entity.global_transform.basis.y * _force_x)
	entity.wheels[3].apply_jump_force(entity.global_transform.basis.y * _force_x)
	entity.wheels[4].apply_jump_force(entity.global_transform.basis.y * _force_x)
	entity.wheels[5].apply_jump_force(entity.global_transform.basis.y * _force_x)
