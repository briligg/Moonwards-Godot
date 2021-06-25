extends AComponent

#The class beneath uses InputEPI via demand.
onready var input : InputEPI = entity.demand_epi(EPIManager.INPUT_EPI)

onready var armature: Skeleton = $"../Model/Legs"

var legs: Array = [] # Holds an instance of Proc_Leg_Rover for each leg

# Some properties are set in setup_movement() directly and don't have a var here, to avoid cluttering
export var wheel_rotation_scale: float = 1.0 # Multiplier for the wheel mesh spin velocity
export var wheel_contact_speed : float = 12.0 # Interpolation value when in contact with the surface
export var wheel_return_speed : float = 2.0 # Interpolation value when not in contact with the surface

export var raise_anim_speed: float = 0.20 # Speed of the animations
export var lower_anim_speed: float = 0.30
export var leg_lift_anim_speed: float = 0.70

# Animation offsets, based on the initial home_target (wheel) positions set in setup_movement
export var raise_anim_offset: float = -3.0
export var lower_anim_offset: float = 3.0
export var leg_lift_offset: float = 11.0


func _init().("RoverAnimation", false):
	pass

func _ready() -> void:
	setup_movement()

func _physics_process(_delta: float) -> void:
	for i in range(legs.size()):
		legs[i].update(_delta)

func setup_movement() -> void:
	var ik_chains: Array = [
		["Thigh.Front.L", "Foot.Front.L"],
		["Thigh.Middle.L", "Foot.Middle.L"],
		["Thigh.Back.L", "Foot.Back.L"],
		["Thigh.Front.R", "Foot.Front.R"],
		["Thigh.Middle.R", "Foot.Middle.R"],
		["Thigh.Back.R", "Foot.Back.R"],
	]
	var ik_magnets: Array = [
		Vector3($"../ik_magnets/magnet_l_f".transform.origin.x, 
				$"../ik_magnets/magnet_l_f".transform.origin.y,
				$"../ik_magnets/magnet_l_f".transform.origin.z),
		Vector3($"../ik_magnets/magnet_l_m".transform.origin.x, 
				$"../ik_magnets/magnet_l_m".transform.origin.y,
				$"../ik_magnets/magnet_l_m".transform.origin.z),
		Vector3($"../ik_magnets/magnet_l_b".transform.origin.x, 
				$"../ik_magnets/magnet_l_b".transform.origin.y,
				$"../ik_magnets/magnet_l_b".transform.origin.z),
		Vector3($"../ik_magnets/magnet_r_f".transform.origin.x, 
				$"../ik_magnets/magnet_r_f".transform.origin.y,
				$"../ik_magnets/magnet_r_f".transform.origin.z),
		Vector3($"../ik_magnets/magnet_r_m".transform.origin.x, 
				$"../ik_magnets/magnet_r_m".transform.origin.y,
				$"../ik_magnets/magnet_r_m".transform.origin.z),
		Vector3($"../ik_magnets/magnet_r_b".transform.origin.x, 
				$"../ik_magnets/magnet_r_b".transform.origin.y,
				$"../ik_magnets/magnet_r_b".transform.origin.z),
	]
	# 2nd arg is the rotation offset for IK
	var ik_ee: Array = [
		[$"../effectors/effector_l_f", Vector3(-90.0, -90.0, 0.0)],
		[$"../effectors/effector_l_m", Vector3(-90.0, -90.0, 0.0)],
		[$"../effectors/effector_l_b", Vector3(-90.0, 0.0, 0.0)],
		[$"../effectors/effector_r_f", Vector3(-90.0, 0.0, 0.0)],
		[$"../effectors/effector_r_m", Vector3(-90.0, 90.0, 0.0)],
		[$"../effectors/effector_r_b", Vector3(-90.0, -90.0, 0.0)],
	]
	# _ready is called on children first so can't use the parent (entity) wheels var - cleaner self-contained anyway
	# 2nd arg is the initial position
	var home_target: Array = [
		[$"../left_front_wheel", 
		Vector3($"../left_front_wheel".transform.origin.x, 
				$"../left_front_wheel".transform.origin.y,
				$"../left_front_wheel".transform.origin.z)],
		[$"../left_mid_wheel", 
		Vector3($"../left_mid_wheel".transform.origin.x, 
				$"../left_mid_wheel".transform.origin.y,
				$"../left_mid_wheel".transform.origin.z)],
		[$"../left_back_wheel", 
		Vector3($"../left_back_wheel".transform.origin.x, 
				$"../left_back_wheel".transform.origin.y,
				$"../left_back_wheel".transform.origin.z)],
		[$"../right_front_wheel", 
		Vector3($"../right_front_wheel".transform.origin.x, 
				$"../right_front_wheel".transform.origin.y,
				$"../right_front_wheel".transform.origin.z)],
		[$"../right_mid_wheel", 
		Vector3($"../right_mid_wheel".transform.origin.x, 
				$"../right_mid_wheel".transform.origin.y,
				$"../right_mid_wheel".transform.origin.z)],
		[$"../right_back_wheel", 
		Vector3($"../right_back_wheel".transform.origin.x, 
				$"../right_back_wheel".transform.origin.y,
				$"../right_back_wheel".transform.origin.z)],
	]
	var wheel_mesh: Array = [
		$"../Model/Legs/WheelFrontLBoneAttachment/Leg-FrontLWheel",
		$"../Model/Legs/WheelMiddleLBoneAttachment/Leg-MiiddleLWheel",
		$"../Model/Legs/WheelBackLBoneAttachment/Leg-BackLWheel",
		$"../Model/Legs/WheelFrontRBoneAttachment/Leg-FrontRWheel",
		$"../Model/Legs/WheellMiddleRBoneAttachment/Leg-MiddleRWheel",
		$"../Model/Legs/WheelBackRBoneAttachment/Leg-BackRWheel",
	]
	
	legs = []
	for i in range(6):
		# IK setup
		var l_ik: SkeletonIK = SkeletonIK.new()
		l_ik.root_bone = ik_chains[i][0]
		l_ik.tip_bone = ik_chains[i][1]
		l_ik.override_tip_basis = true
		l_ik.use_magnet = true
		l_ik.magnet = ik_magnets[i]
		l_ik.target_node = ik_ee[i][0].get_path()
		armature.add_child(l_ik)
		l_ik.start(false)
		
		# Ideally this Y offset should be nearly the same length as the foot bone -> 1.69595 for this model
		# I think leaving some leeway is good, makes the wheel feel grounded, so 1.59 is solid
		var _ik_ee_offset: Vector3 = Vector3(0.0, 1.59, 0.0)
		
		# The rotation offset - needed to align with surfaces
		var _ik_ee_rot_offset: Vector3 = ik_ee[i][1]
		
		# Create instances and store in legs array
		legs.append(
			Proc_Leg_Rover.new(input, entity, ik_ee[i][0], _ik_ee_offset, _ik_ee_rot_offset,
			home_target[i][0], home_target[i][1], wheel_mesh[i],
			wheel_rotation_scale, wheel_contact_speed, wheel_return_speed,
			raise_anim_offset, lower_anim_offset, leg_lift_offset,
			raise_anim_speed, lower_anim_speed, leg_lift_anim_speed)
		)

# Represents a procedural animated leg
class Proc_Leg_Rover:
	var input : InputEPI
	
	var last_ee_pos: Vector3
	
	var entity
	var ik_ee: Spatial
	var ik_ee_pos_offset: Vector3
	var ik_ee_rot_offset: Vector3
	
	var home_target: Spatial
	var home_target_i_pos: Vector3
	var wheel_mesh: MeshInstance
	
	var wheel_rotation_scale: float
	var wheel_contact_speed: float
	var wheel_return_speed: float
	
	var raise_anim_speed: float
	var lower_anim_speed: float
	var leg_lift_anim_speed: float
	
	var raise_anim_offset: float
	var lower_anim_offset: float
	var leg_lift_offset: float
	
	func _init(input_epi : InputEPI, base_parent: Spatial, _ik_ee: Spatial, _ik_ee_pos_offset: Vector3, _ik_ee_rot_offset: Vector3,
	_home_target: Spatial, _home_target_i_pos: Vector3, _wheel_mesh: MeshInstance,
	_wheel_rotation_scale: float, _wheel_contact_speed: float, _wheel_return_speed: float,
	_raise_anim_offset: float, _lower_anim_offset: float, _leg_lift_offset: float,
	_raise_anim_speed: float, _lower_anim_speed: float, _leg_lift_anim_speed: float
	) -> void:
		input = input_epi
		
		entity = base_parent
		ik_ee = _ik_ee
		ik_ee_pos_offset = _ik_ee_pos_offset
		ik_ee_rot_offset = _ik_ee_rot_offset
		
		home_target = _home_target
		home_target_i_pos = _home_target_i_pos
		wheel_mesh = _wheel_mesh
		
		# Set the initial home target position
		(home_target as Spatial).transform.origin = home_target_i_pos
		
		wheel_rotation_scale = _wheel_rotation_scale
		wheel_contact_speed = _wheel_contact_speed
		wheel_return_speed = _wheel_return_speed
		raise_anim_speed = _raise_anim_speed
		lower_anim_speed = _lower_anim_speed
		leg_lift_anim_speed = _leg_lift_anim_speed
		raise_anim_offset = _raise_anim_offset
		lower_anim_offset = _lower_anim_offset
		leg_lift_offset= _leg_lift_offset
		
		ik_ee.global_transform.origin = home_target.global_transform.origin + ik_ee_pos_offset
		ik_ee.rotation_degrees = ik_ee_rot_offset
	
	
	func align_with_y(xform: Transform, new_y: Vector3) -> Transform:
		xform.basis.y = new_y
		xform.basis.x = -xform.basis.z.cross(new_y)
		xform.basis = xform.basis.orthonormalized()
		return xform
	
	
	func update(delta: float) -> void:
		handle_maneuver(delta)
		
		# Match steer
		ik_ee.rotation_degrees = ik_ee_rot_offset
		ik_ee.rotation_degrees.y += home_target.rotation_degrees.y
		
		# Spin
		var instant_vel: Vector3 = (ik_ee.global_transform.origin - last_ee_pos) / delta
		var z_component: float = home_target.global_transform.basis.xform_inv(instant_vel).z
		
		# Front-right wheel has rotation in diff axis
		if entity.wheels[3] == home_target:
			wheel_mesh.global_rotate(-(wheel_mesh as Spatial).global_transform.basis.z.normalized(), 
				z_component * wheel_rotation_scale * delta)
		else:
			wheel_mesh.global_rotate((wheel_mesh as Spatial).global_transform.basis.y.normalized(), 
				z_component * wheel_rotation_scale * delta)
		
		
		# Set position
		var new_pos: Vector3 = (home_target.collision_pos + ik_ee_pos_offset)
		if home_target.is_grounded:
			ik_ee.global_transform.origin = lerp(ik_ee.global_transform.origin, new_pos, wheel_contact_speed * delta)
		else:
			ik_ee.global_transform.origin = lerp(ik_ee.global_transform.origin, new_pos, wheel_return_speed * delta)
		
		last_ee_pos = ik_ee.global_transform.origin
		return
	
	
	func handle_maneuver(delta: float) -> void:
		if input.is_leg_state(input.Leg_Anim_States.RAISE) :
			var dir: Vector3 = Vector3(0.0, home_target_i_pos.y, 0.0).direction_to(home_target_i_pos)
			var target_pos_xz: Vector3 = home_target_i_pos + dir * raise_anim_offset
			var target_pos: Vector3 = Vector3(target_pos_xz.x, home_target_i_pos.y + raise_anim_offset, target_pos_xz.z)
			
			home_target.translation = lerp(home_target.translation, target_pos, (1.0 - exp(-raise_anim_speed * delta)))
			
		elif input.is_leg_state(input.Leg_Anim_States.LOWER) :
			var dir: Vector3 = Vector3(0.0, home_target_i_pos.y, 0.0).direction_to(home_target_i_pos)
			var target_pos_xz: Vector3 = home_target_i_pos + dir * lower_anim_offset
			var target_pos: Vector3 = Vector3(target_pos_xz.x, home_target_i_pos.y + lower_anim_offset, target_pos_xz.z)
			
			home_target.translation = lerp(home_target.translation, target_pos, (1.0 - exp(-lower_anim_speed * delta)))
			
		elif input.is_leg_state(input.Leg_Anim_States.LIFT_LEG) :
			if home_target == entity.wheels[0]:
				var target_pos: Vector3 = Vector3(home_target_i_pos.x, 
					home_target_i_pos.y + leg_lift_offset, home_target_i_pos.z)
				
				home_target.translation = lerp(home_target.translation, target_pos, 
					(1.0 - exp(-leg_lift_anim_speed * delta)))
			

