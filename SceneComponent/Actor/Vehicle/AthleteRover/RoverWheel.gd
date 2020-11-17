extends Spatial
class_name Custom_Wheel

export var ENABLE_DEBUG: bool = false # TODO remove this if not needed

# Control properties
export var wheel_radius: float = 0.75 # Physical radius, needs to match the mesh - use debug visualization to ensure
export var max_spring_force: float = 17580.0 # Should be about 6x the weight  14580.0
export var spring_force: float = 3500.0 # About 1/4th the max force
export var stifness: float = 0.06 # 0.15
export var damping_force: float = 0.07
export var traction_x: float = 0.95
export var traction_z: float = 0.04
export var normal_cast_to: Vector3 = Vector3(0.0, -11.5, 0.0) # A value close, but lesser than the max extension intended for a leg
var cast_to: Vector3 = normal_cast_to # A value close, but lesser than the max extension intended for a leg
export var rigor_mortis_thres: float = -0.5 # Threshold to enter rigor_mortis
export var cast_to_rigor_mortis: Vector3 = Vector3(0.0, 3.5, 0.0)


# Godot has no direct way to perform sphere_casts, so we do it manually
# Classes are easier to maintain than dictionaries
class Sphere_Cast_Result:
	var is_hit: bool
	var hit_distance: float
	var hit_position: Vector3
	var hit_normal: Vector3

onready var vehicle_entity: RigidBody = get_parent()
var instant_linear_vel: Vector3
var previous_distance: float = cast_to.length()
var previous_hit: Sphere_Cast_Result = Sphere_Cast_Result.new()
var collision_pos: Vector3 = cast_to
var collision_normal: Vector3 = Vector3.UP
var suspension_vector: Vector3
var is_grounded: bool = false



func _physics_process(delta: float) -> void:
	# If entity is upside down, reverse cast_to and lessen it
	if vehicle_entity.global_transform.basis.y.dot(Vector3.UP) < rigor_mortis_thres:
		cast_to = cast_to_rigor_mortis
	else:
		cast_to = normal_cast_to
	
	var cast_res: Sphere_Cast_Result = sphere_cast(global_transform.origin, cast_to, wheel_radius)
	collision_pos = cast_res.hit_position
	collision_normal = cast_res.hit_normal
	if ENABLE_DEBUG: # TODO remove this if not needed
		DebugDraw.c_draw_cube(collision_pos, wheel_radius, Color(255,255,255)) 
		DebugDraw.c_draw_cube(global_transform.origin, .5, Color(255,0,255))
	
	if cast_res.is_hit:
		is_grounded = true
		
		instant_linear_vel = (collision_pos - previous_hit.hit_position) / delta
		
		# Suspension / spring
		var cur_distance: float = cast_res.hit_distance
		var _spring_f: float = stifness * (cast_to.length() - cur_distance) 
		var _damp_f: float = damping_force * (previous_distance - cur_distance) / delta
		var _suspension_force: float = clamp((_spring_f + _damp_f) * spring_force, 0.0, max_spring_force)
		suspension_vector = global_transform.basis.y * _suspension_force * delta
		
		# Local vel components along ground axes
		var loc_vel_z: float = global_transform.basis.xform_inv(instant_linear_vel).z
		var loc_vel_x: float = global_transform.basis.xform_inv(instant_linear_vel).x
		
		# Deceleration and traction
		var _force_x: Vector3 = (-global_transform.basis.x * loc_vel_x * 
			(vehicle_entity.weight * vehicle_entity.gravity_scale) / vehicle_entity.wheels.size() * traction_x * delta )
		var _force_z: Vector3 = (-global_transform.basis.z * loc_vel_z * 
			(vehicle_entity.weight * vehicle_entity.gravity_scale)/vehicle_entity.wheels.size() * traction_z * delta )
		
		# Mitigate sliding
		_force_x.x -= suspension_vector.x * vehicle_entity.global_transform.basis.y.dot(Vector3.UP)
		_force_z.z -= suspension_vector.z * vehicle_entity.global_transform.basis.y.dot(Vector3.UP)
		
		var final_force: Vector3 = suspension_vector + _force_x + _force_z
		
		if ENABLE_DEBUG: # TODO remove this if not needed
			DebugDraw.c_draw_ray(collision_pos, suspension_vector, Color(0,255,0))
			DebugDraw.c_draw_ray(collision_pos, _force_x, Color(255,0,0))
			DebugDraw.c_draw_ray(collision_pos, _force_z, Color(0,0,255))
		
		# apply_impulse uses the rotation of the global coordinate system, but is centered at the object's origin
		vehicle_entity.apply_impulse(
			vehicle_entity.global_transform.basis.xform( vehicle_entity.to_local(collision_pos) ),
			final_force)
		
		previous_distance = cur_distance
		previous_hit = cast_res
	else:
		is_grounded = false
		previous_hit = Sphere_Cast_Result.new()
		previous_hit.is_hit = false
		previous_hit.hit_position = global_transform.origin + cast_to
		previous_hit.hit_distance = cast_to.length()
		previous_distance = previous_hit.hit_distance


# Called by the vehicle entity
func apply_engine_force(_force: Vector3) -> void:
	if is_grounded:
		# apply_impulse uses the rotation of the global coordinate system, but is centered at the object's origin
		vehicle_entity.add_force(
				_force,
				vehicle_entity.global_transform.basis.xform( vehicle_entity.to_local(collision_pos) )
			)


func apply_jump_force(_force: Vector3) -> void:
	if is_grounded:
		# apply_impulse uses the rotation of the global coordinate system, but is centered at the object's origin
		vehicle_entity.apply_impulse(
			vehicle_entity.global_transform.basis.xform( vehicle_entity.to_local(collision_pos) ),
			_force * suspension_vector)
		
		DebugDraw.c_draw_ray(collision_pos, _force*.01, Color(0,0,255), 2.0)


func sphere_cast(origin: Vector3, to_offset: Vector3, radius: float) -> Sphere_Cast_Result:
	var space: PhysicsDirectSpaceState = (get_world().direct_space_state as PhysicsDirectSpaceState)
	
	var shape: = SphereShape.new()
	shape.radius = radius
	
	var params: = PhysicsShapeQueryParameters.new()
	params.set_shape(shape)
	params.transform = Transform.IDENTITY
	params.transform.origin = origin
	params.exclude = [vehicle_entity]
	params.margin = 0.0
	
	""" cast_motion
	Checks whether the shape can travel to a point. The method will return an array with two floats between 0 and 1, 
	both representing a fraction of motion. The first is how far the shape can move without triggering a collision, 
	and the second is the point at which a collision will occur. If no collision is detected, the returned array will 
	be [1, 1].
	If the shape can not move, the returned array will be [0, 0] under Bullet, and empty under GodotPhysics.
	"""
	var cast_result: Array = space.cast_motion(params, to_offset) # Array of floats

	var _ret: Sphere_Cast_Result = Sphere_Cast_Result.new()
	_ret.is_hit = true
	if cast_result[0] >= .999 and cast_result[1] >= .999:
		_ret.is_hit = false
	
	_ret.hit_distance = cast_result[0] * to_offset.length()
	_ret.hit_position = origin + to_offset * cast_result[0]
	
	params.transform.origin = origin + to_offset * cast_result[1]
	
	var coll_dict: Dictionary = space.get_rest_info(params)
	_ret.hit_normal = coll_dict.get("normal", Vector3.ZERO)
	
	return _ret
