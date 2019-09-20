extends KinematicBody

export(bool) var debug = false

var CHAR_SCALE = Vector3(0.3, 0.3, 0.3)
var MaleAvatar = preload("res://model_assets/Avatars/MalePlayer.tscn")
var FemaleAvatar = preload("res://model_assets/Avatars/FemalePlayer.tscn")
export(bool) var is_female
var facing_dir = Vector3(1, 0, 0)
var movement_dir = Vector3()
var jumping = false
var aimrotation = Vector3()
export(int) var turn_speed = 40
export(bool) var air_idle_deaccel = false
export(bool) var fixed_up = true
export(float) var accel = 19.0
export(float) var deaccel = 14.0
export(float) var sharp_turn_threshold = 140
export(float) var JumpHeight = 1.5
var Captured = true
var chatting = false
export(bool) var AllowChangeCamera = false
export(bool) var FPSCamera = true
export(bool) var thRDPersCamera = false
var flies = false
var translationcamera
var ActionArea = false

var ismoving = false
var up

#State
var input_processing = true setget set_player_input
var nocamera = false setget set_player_nocamera
var nonetwork = true setget set_nonetwork
var network = !nonetwork setget set_network
var username
#Options
export(float) var WALKSPEED = 3.1
export(float) var RUNSPEED = 4.5
export(float) var view_sensitivity = 0.5
export var weight= 1
export(NodePath) var Camera = "Pivot/FPSCamera"
var AnimatedCharacter 
##Physics
export(float) var grav = 1.6
var gravity = Vector3(0,-grav,0)

var max_speed = 0.0
var max_speed_vertical = 20 * RUNSPEED #limit general falling speed, even if probably not required

var linear_velocity=Vector3()
var hspeed = 0

##Networking
var puppet = false
puppet var puppet_translation
puppet var puppet_transform
puppet var puppet_linear_vel
puppet var puppet_animation

#####################
#var debug = true
var debug_id = "Player.gd:: "
var debug_list = [
	{ enable = false, key = "player move/slide" },
	{ enable = false, key = "network_master 1, update pupet" },
#	{ enable = true, key = "" }
]
func printd(s):
	if debug:
		if debug_list.size() > 0:
			var found = false
			for dl in debug_list:
				if s.begins_with(dl.key):
					if dl.enable:
						print(debug_id, s)
					found = true
					break
			if not found:
				print(debug_id, s)
		else:
			print(debug_id, s)
#####################
## Set/Get functions
func _enter_tree():
	printd("Player enter tree")
	var Player
	printd("Player %s select avatar, female(%s)" % [get_path(), is_female])
	if is_female:
		Player = FemaleAvatar.instance()
	else:
		Player = MaleAvatar.instance()
	
	Player.name = "Scene"
# 	Player.rotation_degrees.y = -90
	$Model.add_child(Player)
	AnimatedCharacter = $Model/Scene
	#max_speed = WALKSPEED #init value, is modifyed by mode_run function, if req
	mode_run(false)

func set_nonetwork(state):
	nonetwork = state
	network = !nonetwork

	printd("Player %s enable/disable networking, nonetwork(%s)" % [get_path(), nonetwork])
	if nonetwork:
		rset_config("puppet_translation", MultiplayerAPI.RPC_MODE_DISABLED)
		rset_config("puppet_transform",  MultiplayerAPI.RPC_MODE_DISABLED)
		rset_config("puppet_linear_vel", MultiplayerAPI.RPC_MODE_DISABLED)
	else:
		rset_config("puppet_translation", MultiplayerAPI.RPC_MODE_PUPPET)
		rset_config("puppet_transform",  MultiplayerAPI.RPC_MODE_PUPPET)
		rset_config("puppet_linear_vel",  MultiplayerAPI.RPC_MODE_PUPPET)

func set_network(state):
	set_nonetwork(!state)

#disable camera view for the player
func set_player_nocamera(state):
	nocamera = state
	printd("Player %s enable/disable camera, nocamera(%s)" % [get_path(), nocamera])
	if nocamera :
		get_node("Pivot").visible = false
		get_node("Pivot/FPSCamera").clear_current()
	else:
		get_node("Pivot").visible = true
		get_node("Pivot/FPSCamera").make_current()

#Rotates the model to where the camera points
func adjust_facing(p_facing, p_target, p_step, p_adjust_rate, current_gn):
	var n = p_target # Normal
	var t = n.cross(current_gn).normalized()

	var x = n.dot(p_facing)
	var y = t.dot(p_facing)

	var ang = atan2(y,x)

	if (abs(ang) < 0.001): # Too small
		return p_facing

	var s = sign(ang)
	ang = ang*s
	var turn = ang*p_adjust_rate*p_step
	var a
	if (ang < turn):
		a = ang
	else:
		a = turn
	ang = (ang - a)*s

	return (n*cos(ang) + t*sin(ang))*p_facing.length()

func set_player_input(enable):
	printd("Player %s enable/disable input, enable(%s)" % [get_path(), enable])
	if not enable:
		self.get_node(Camera).noinput = true
		Captured = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		self.get_node(Camera).noinput = false
		Captured = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input_processing = enable

func mode_run(enable):
	if enable:
		max_speed=WALKSPEED
	else:
		max_speed=RUNSPEED
	
	if flies:
		max_speed = 2 * max_speed
	printd("player mode, run(%s) max speed(%s), fly(%s); %s" % [enable, max_speed, flies, get_path()])

func mode_fly(enable=null):
	flies = !flies
	if enable != null:
		flies = enable
	printd("player mode, fly set to %s; %s" % [flies, get_path()])

func cursor_toggle():
	match Input.get_mouse_mode():
		Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			printd("player set cursor to captured")
		Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			printd("player set cursor to visible")
		_:
			print("player cursor_toggle, do not know what to do, current mode %s at player %s" % [Input.get_mouse_mode(), get_path()])

func _input(event):
	# disable enable imput processing, mostly for networ players, they totaly slave of their state
	if network:
		return
	if Input.is_action_pressed("player_toggleinput"):
		input_processing = !input_processing
		set_player_input(input_processing)
		
	if not input_processing:
		return

	#### RAYCAST ####
	var Raycast = $Pivot/FPSCamera.get_node("RayCast")
	if Raycast.is_colliding():
		var collider = Raycast.get_collider()
		var click_position = Raycast.get_collision_point()
		var click_normal = Raycast.get_collision_normal()
		if collider is Area:
			collider._input_event (get_viewport().get_camera(), event, click_position, click_normal, 0 )
	
	if Input.is_action_just_pressed("ui_cancel"):
		printd("event ui_cancel")
		cursor_toggle()
	
	if Input.is_action_just_pressed("move_run"):
		mode_run(true)
	if Input.is_action_just_released("move_run"):
		mode_run(false)
	
	if Input.is_action_just_pressed("toggle_fly"):
		mode_fly()

func _physics_process_puppet(delta):
	if not (puppet_transform == null or puppet_translation == null or puppet_linear_vel == null):
		printd("set puppet(%s) delta(%s) t(%s) lv(%s)" % [name, delta, puppet_translation, puppet_linear_vel])
		translation = puppet_translation
#		$Yaw.transform = puppet_transform
		linear_velocity = puppet_linear_vel
	else:
		printd("no set puppet(%s) delta(%s) t(%s) lv(%s)" % [name, delta, puppet_translation, puppet_linear_vel])

func _physics_process(delta):
	printd("_physics_process  node %s; network/puppet/input(%s/%s/%s); delta(%s)" % [name, network, puppet, input_processing, delta])
	if network and puppet:
		_physics_process_puppet(delta)

	if not input_processing:
		return

		
	var v_speed 

	if not flies:
		linear_velocity += gravity*delta/weight # Apply gravity
	
	if fixed_up:
		 up = Vector3(0,1,0) # (up is against gravity)
	else:
		 up = -gravity.normalized()
	var vertical_velocity = up.dot(linear_velocity) # Vertical velocity
	var horizontal_velocity = linear_velocity - up*vertical_velocity # Horizontal velocity
	var hdir = horizontal_velocity.normalized() # Horizontal direction
	hspeed = horizontal_velocity.length() # Horizontal speed

#Movement
	var dir = Vector3() # Where does the player intend to walk to

	var AbsView = ($Pivot/FPSCamera/Target.get_global_transform().origin-$Pivot/FPSCamera.get_global_transform().origin).normalized() 
	#This is the global vector for the player to move while flying
	
	#THIS BLOCK IS INTENDED FOR FPS CONTROLLER USE ONLY
	var aim = $Pivot/FPSCamera.get_global_transform().basis

	if Input.is_action_pressed("move_forwards"):
		if not flies:
			dir -= aim[2]
		else:
			dir += AbsView
	if Input.is_action_pressed("move_backwards"):
		if not flies:
			dir += aim[2]
		else:
			dir -= AbsView
	if Input.is_action_pressed("move_forwards") or Input.is_action_pressed("move_backwards"):
		ismoving = true
	else:
		ismoving = false
	
	if (Input.is_action_pressed("move_left")):
		dir -= aim[0]

		$Pivot/FPSCamera.Znoice =  1*hspeed

	if (Input.is_action_pressed("move_right")):
		dir += aim[0]
		$Pivot/FPSCamera.Znoice =  -1*hspeed
	

	if flies:
		vertical_velocity += dir.y
	
	if network:
		printd("network_master(%s for %s) %s, update pupet %s %s" % [is_network_master(), get_network_master(), name, translation, linear_velocity])
		if is_network_master():
			rset_unreliable("puppet_translation", translation)
			rset_unreliable("puppet_transform", $Model.transform)
			rset_unreliable("puppet_linear_vel", linear_velocity)

# 	var jump_attempt = (Input.is_action_pressed("jump") or (Input.is_action_pressed("ui_page_up") and flies))
	var jump_attempt = Input.is_action_pressed("jump")
# 	var crouch_attempt = (Input.is_action_pressed("ui_mlook") or (Input.is_action_pressed("ui_page_down") and flies))
	var crouch_attempt = Input.is_action_pressed("ui_mlook")
	
	
#END OF THE BLOCK


	var target_dir = (dir - up*dir.dot(up)).normalized()

	if (is_on_floor() or flies): #Only lets the character change it's facing direction when it's on the floor or flying.
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold

		if (dir.length() > 0.1 and !sharp_turn):
			if (hspeed > 0.001):
				
				hdir = adjust_facing(hdir, target_dir, delta, 1.0/hspeed*turn_speed, up)
				facing_dir = hdir
			else:
				hdir = target_dir


			if (hspeed < max_speed):
				hspeed += accel*delta
			else:
				if hspeed > 0:
					hspeed -= deaccel*delta
					if Input.is_action_pressed("move_forwards"):
						AnimatedCharacter.start_walk(hspeed, true)
					elif Input.is_action_pressed("move_backwards"):
						AnimatedCharacter.start_walk(hspeed, false)
						
		else:
			hspeed -= deaccel*delta
			if (hspeed < 0):
				hspeed = 0
				AnimatedCharacter.idle()

		horizontal_velocity = hdir*hspeed

		var mesh_xform = $Model.transform
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - up*facing_mesh.dot(up)).normalized()

		if (hspeed>0):
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0/hspeed*turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(scale)
		if not Input.is_action_pressed("move_backwards"):
			$Model.set_transform(Transform(m3, mesh_xform.origin))

		if (not jumping and jump_attempt):
			vertical_velocity = JumpHeight
			jumping = true
	else:
		if flies:
			
			if (hspeed < max_speed):
				hspeed += accel*delta
			else:
				if hspeed > 0:
					hspeed -= deaccel*delta
			
		if (vertical_velocity > 0):
			pass
			#print(ANIM_AIR_UP) #Placeholder
		else:
			pass
			#print(ANIM_AIR_DOWN)
		if (dir.length() > 0.1):
			horizontal_velocity += target_dir*accel*delta
				
			if (horizontal_velocity.length() > max_speed):
				horizontal_velocity = horizontal_velocity.normalized()*max_speed
		else:
			if (air_idle_deaccel):
				hspeed = hspeed - (deaccel*0.2)*delta
				if (hspeed < 0):
					hspeed = 0
				horizontal_velocity = hdir*hspeed

	if (jumping and vertical_velocity < 0):
		jumping = false
		
	if flies: 
		if crouch_attempt:
			vertical_velocity -= delta*accel
			
		if jump_attempt:
			vertical_velocity += delta*accel
			
		if vertical_velocity < -0.1:
			vertical_velocity += delta*deaccel
		
		if vertical_velocity > 0.1:
			
			vertical_velocity -= delta*deaccel
			
		if vertical_velocity < 0.1 and vertical_velocity > -0.1:
			vertical_velocity = 0
			
			
		if vertical_velocity > max_speed_vertical:
			vertical_velocity = max_speed_vertical
			printd("veritcal velocity(%s) vs max_speed(%s)" % [vertical_velocity, max_speed_vertical])
	
	linear_velocity = horizontal_velocity + up*vertical_velocity

	if (is_on_floor()):
		movement_dir = linear_velocity

	printd("player move/slide v %s g %s d %s ms %s" % [linear_velocity,-gravity.normalized(), dir, max_speed])
	linear_velocity = move_and_slide(linear_velocity,-gravity.normalized())

	if not nocamera:
		if AllowChangeCamera:
			if Input.is_action_pressed("cameraFPS"): #Not implemented yet
				$Pivot/FPSCamera.make_current()
				$Pivot/FPSCamera.restrictaxis = false

			if Input.is_action_pressed("camera3RD"): #Not implemented yet
				get_node("Pivot/3RDPersCamera").make_current()
				$Pivot/FPSCamera.restrictaxis = false
		aimrotation = $Pivot/FPSCamera.rotation_degrees
		translationcamera=$Pivot/FPSCamera.get_global_transform().origin

func _ready():
#	$Model/Model.get_surface_material(0).albedo_color = options.get("player", "color")
	if not username:
		set_player_name(options.get("player", "name"))
	else:
		set_player_name(username)
	
	CHAR_SCALE = scale
	set_process_input(true)
	if input_processing:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Pivot/FPSCamera.initiate_3rd_person()

func set_player_name(new_name):
	get_node("label").set_text(new_name)
#	$Pivot/FPSCamera/Chat.username = new_name
	username = new_name
	
func toggle_chatting():
	if chatting:
		chatting = false
	else:
		chatting = true
