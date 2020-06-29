extends Spatial

# A variable to hold the Editor_Controller node.
var editor_controller;

# A custom signal we will emit when a new physics object has been selected. This can be one of the following nodes: StaticBody,
# RigidBody, or KinematicBody.
signal physics_object_selected(object);

# A variable to hold the collision layer all of the 'normal' nodes are on. Anything on this layer will be selectable.
# See (https://godotengine.org/qa/17896/collision-layer-and-masks-in-gdscript) for details on how
# to convert a collision layer into a integer!
const NORMAL_COLLISION_LAYER = 1;

# A variable to hold the speed the camera moves at when the control key is held down.
const CONTROL_SPEED = 2;
# A variable to hold the speed the camera moves at normally.
const MOVE_SPEED = 10;
# A variable to hold the speed the camera moves at when the shift key is held down.
const SHIFT_SPEED = 20;

# A variable to store how sensitive the mouse is. You may need to change this depending on the sensitivity of your mouse.
const MOUSE_SENSITIVTY = 0.05;

# A variable to hold the camera that will render the scene.
var view_camera = null;

# A constant variable to define how far the camera can move on the X axis when in free look mode.
const CAMERA_MAX_ROTATION_ANGLE = 70;

# A variable for holding whether we need to send out a raycast on the next _physics_process call.
var send_raycast = false;


func _ready():
	# Get the Editor_Contoller node and assign it to editor_controller.
	# 
	# NOTE: using get_parent assumes that the parent of this node is Editor_Controller.
	# Depending on your project, this may or may not be a safe assumption.
	editor_controller = get_parent();
	
	# Get the camera that will render the scene and assign it to the view_camera variable.
	view_camera = get_node("View_Camera");


func _process(delta):
	# If the right mouse button is pressed/held...
	if (Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		# If the current mouse mode is not MOUSE_MODE_CAPTURED, then capture the mouse by setting the mouse mode to MOUSE_MODE_CAPTURED.
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
		
		# Tell the editor_controller that the camera is in free look mode.
		editor_controller.is_in_freelook_mode = true;
	
	# If the right mouse button is NOT pressed/held...
	else:
		# If the current mouse mode is not MOUSE_MODE_VISIBLE, then free the mouse by setting the mouse mode to MOUSE_MODE_VISIBLE.
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		
		# Tell the editor_controller that the camera is no longer in free look mode.
		editor_controller.is_in_freelook_mode = false;
	
	# If editor_controller is in free look mode...
	if (editor_controller.is_in_freelook_mode == true):
		# Process camera movement!
		process_movement(delta);


func process_movement(delta):
	# Make two new variables. One to store the direction the player intends to go (movement_vector) and another
	# to store how fast the camera should move at.
	var movement_vector = Vector3(0, 0, 0);
	var movement_speed = MOVE_SPEED;
	
	# If the "editor_move_forward" action is pressed/down, set movement_vector's Z axis to 1, while if the
	# "editor_move_backward" action is pressed/down, set movement_vector's Z axis to -1.
	if (Input.is_action_pressed("editor_move_forward") == true):
		movement_vector.z = 1;
	elif (Input.is_action_pressed("editor_move_backward") == true):
		movement_vector.z -= 1;
	
	# If the "editor_move_right" action is pressed/down, set movement_vector's X axis to 1, while if the
	# "editor_move_left" action is pressed/down, set movement_vector's X axis to -1.
	if (Input.is_action_pressed("editor_move_right") == true):
		movement_vector.x = 1;
	elif (Input.is_action_pressed("editor_move_left") == true):
		movement_vector.x = -1;
	
	# If the shift key is pressed/held, then set movement_speed to SHIFT_SPEED, while if the control key is pressed/held, set
	# movement_speed to CONTROL_SPEED.
	if (Input.is_key_pressed(KEY_SHIFT)):
		movement_speed = SHIFT_SPEED;
	elif (Input.is_key_pressed(KEY_CONTROL)):
		movement_speed = CONTROL_SPEED;
	
	# This will move everything forward according to the direction the view_camera is looking (the camera's negative Z axis)
	# multipled by movement_vector's Z axis, mutlipled by movement_speed and delta.
	#
	# This will move the camera forwards/backwards according to where the camera is facing!
	global_transform.origin += -view_camera.global_transform.basis.z * movement_vector.z * movement_speed * delta;
	# Likewise, this will move everything right/left according to the direction the view_camera is facing (the camera's X axis)
	# multipled by movement_vector's X axis, mutlipled by movement_speed and delta.
	#
	# This will move the camera right/left according to where the camera is facing!
	global_transform.origin += view_camera.global_transform.basis.x * movement_vector.x * movement_speed * delta;


func _unhandled_input(event):
	# If the editor is in free look mode...
	if (editor_controller.is_in_freelook_mode == true):
		# If the event is a InputEventMouseMotion event (the mouse moved)...
		if (event is InputEventMouseMotion):
			# If the mouse moved, then we need to rotate the camera based on said mouse movement
			# First, get the camera's current rotation.
			var camera_rotation = view_camera.rotation_degrees;
			# On the camera's X axis, add the mouse motion mutlipled by MOUSE_SENSITVITY.
			# To ensure the camera cannot be upside down, we will use the clamp function and pass in -CAMERA_MAX_ROTATION_ANGLE as the minimum
			# value, and CAMERA_MAX_ROTATION_ANGLE as the maximum value.
			camera_rotation.x = clamp(camera_rotation.x + (-event.relative.y * MOUSE_SENSITIVTY), -CAMERA_MAX_ROTATION_ANGLE, CAMERA_MAX_ROTATION_ANGLE);
			
			# Rotate everything on the Y axis. Unlike the X axis, we can rotate as much as we want so we do not need to clamp anything.
			rotation_degrees.y += -event.relative.x * MOUSE_SENSITIVTY;
			
			# Apply the camera's new rotation
			view_camera.rotation_degrees = camera_rotation;
	
	# If the editor is NOT in free look mode...
	else:
		# If the event is a InputEventMouseButton event (one of the mouse buttons)
		if (event is InputEventMouseButton):
			# If the mouse button tied to this event is the left mouse button, and the mouse button was just pressed..
			if (event.button_index == BUTTON_LEFT and event.pressed == true):
				# If the current editor mode is SELECT...
				if (editor_controller.editor_mode == "SELECT"):
					# Send out a raycast!
					send_raycast = true;


func _physics_process(delta):
	# If send_raycast is true...
	if (send_raycast == true):
		# Then we need to send out a raycast.
		# First, set send_raycast to false so we only send out a single raycast.
		send_raycast = false;
		
		# Make a new variable to hold the node we select, if the raycast collides with a node.
		var selected_node = null;
		
		# Get the direct space state. NOTE: this is the space state for the root viewport, not the Editor_Viewport!
		var space_state = get_world().direct_space_state;
		
		# Get the starting position and end position of the raycast we want to create.
		# See (https://docs.godotengine.org/en/3.0/tutorials/physics/ray-casting.html) for more details on how to raycast using a camera!
		var raycast_from = view_camera.project_ray_origin(get_tree().root.get_mouse_position())
		var raycast_to = raycast_from + view_camera.project_ray_normal(get_tree().root.get_mouse_position()) * 100;
		
		# Send out a raycast and store the results of the raycast into a new variable called result.
		# Note that we are passing in NORMAL_COLLISION_LAYER, so the raycast will only collide with objects on that layer!
		var result = space_state.intersect_ray(raycast_from, raycast_to, [self], NORMAL_COLLISION_LAYER);
		
		# If there is something stored within result...
		if (result.size() > 0):
			# Then set selected_node to the collider the raycast collided with.
			selected_node = result.collider;
		
		# Finally, emit the "physics_object_selected" signal and pass selected_node. If no nodes were selected, then
		# selected_node will be null, while if a node was selected then selected_node will be the collider the raycast collided with.
		emit_signal("physics_object_selected", selected_node);
		




