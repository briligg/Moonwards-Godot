extends Spatial

# A NodePath to the Editor_Viewport node.
export (NodePath) var path_to_editor_viewport;
# A variable to hold the Editor_Viewport node.
var editor_viewport;

# A variable to hold the currently active axis.
# NOTE: we are making this a exported variable so we can check its value from the remote debugger.
export (String, "ALL", "X", "Y", "Z", "NONE") var active_gizmo_axis;

# A variable to store whether the left mouse button is down or not.
var left_button_down = false;

# The speed the rotation gizmo changes the rotation of the selected object when using look_at.
const LOOK_AT_ROTATION_SPEED = 4;
# The speed the rotation gizmo changes the rotation of the selected object when constrained to a single axis.
# With both of these constants, you may need to tweak this based on the sensitivity of your mouse and/or how fast you want
# the gizmo to rotate the object.
const ROTATION_SPEED = 1;


func _ready():
	# Get the Editor_Viewport node using path_to_editor_viewport and assign it to editor_viewport.
	editor_viewport = get_node(path_to_editor_viewport);
	
	# Make the gizmo disabled by default.
	update(false);
	
	# Set the default gizmo axis to NONE.
	active_gizmo_axis = "NONE";


func _input(event):
	# If the active gizmo axis is NOT set to NONE...
	if (active_gizmo_axis != "NONE"):
		
		# If the input event is a InputEventMouseButton event (a mouse button was pressed/held/released)...
		if (event is InputEventMouseButton):
			# If the mouse button is the left mouse button...
			if (event.button_index == BUTTON_LEFT):
				# Set left_button_down to the result of the is_pressed() function in the input event.
				# Unlike the pressed variable, is_pressed will return true if the button is pressed AND when the button is held.
				left_button_down = event.is_pressed();
		
		# If the event is a InputEventMouseMotion event (the mouse was moved).
		elif (event is InputEventMouseMotion):
			# If the left mouse button is pressed or held down...
			if (left_button_down == true):
				# If there is a selected object...
				if (editor_viewport.selected_physics_object != null):
					# Store the current rotation of the selected object in a new variable called prior_rotation.
					var prior_rotation = editor_viewport.selected_physics_object.rotation_degrees;
					# Make a new variable called current_rotation and assign it to prior_rotation.
					var current_rotation = prior_rotation;
					
					# If the active gizmo axis is ALL...
					if (active_gizmo_axis == "ALL"):
						# NOTE: this does not work like a 'normal' free rotation system, but I couldn't find a way to get
						# it working like the rotation gizmo in some programs, so this is a workable approximation instead!
						
						# Assign the relative position of the mouse (event.relative) multiplied by LOOK_AT_ROTATION_SPEED to a variable called mouse_delta.
						var mouse_delta = event.relative * LOOK_AT_ROTATION_SPEED;
						
						# Get the origin of a raycast and pass the mouse position. This will give us a position on the viewport where the mouse is.
						var raycast_from = editor_viewport.gizmo_camera.project_ray_origin(editor_viewport.get_mouse_position())
						
						# Calculate the distance from the gizmo camera to the selected physics object and assign the results to a new variable called
						# obj_distance.
						var obj_distance = (editor_viewport.gizmo_camera.global_transform.origin - editor_viewport.selected_physics_object.global_transform.origin).length()
						
						# Calculate the end point of the 'raycast' using the same method we use for raycasting, but multiply it by obj_distance so it is positioned
						# along the same plane as the selected object.
						var raycast_to = raycast_from + editor_viewport.gizmo_camera.project_ray_normal(editor_viewport.get_mouse_position()) * obj_distance;
						
						# Finally, use the look_at function to make selected_physics_object look at the position stored within raycast_to.
						editor_viewport.selected_physics_object.look_at(raycast_to, Vector3(0,1,0));
					
					# If the active gizmo axis is NOT set to ALL...
					else:
						# Assign the relative position of the mouse (event.relative) multiplied by ROTATION_SPEED to a variable called mouse_delta.
						var mouse_delta = event.relative * ROTATION_SPEED;
						
						# Add the gizmo camera's relative Y axis multiplied by mouse_delta on the X axis. This will (sort of) rotate the gizmo
						# around the Y axis, but relative to the gizmo camera.
						current_rotation += editor_viewport.selected_physics_object.global_transform.basis.y * mouse_delta.x;
						# Add the gizmo camera's relative X axis multiplied by negative mouse_delta on the Y axis. This will (sort of) rotate the gizmo
						# around the X axis, but relative to the gizmo camera.
						current_rotation += editor_viewport.selected_physics_object.global_transform.basis.x * -mouse_delta.y;
						
						# If the active gizmo axis is the X axis...
						if (active_gizmo_axis == "X"):
							# Then reset current_rotation on the Y and Z axis to the rotation stored in prior_rotation.
							current_rotation.y = prior_rotation.y;
							current_rotation.z = prior_rotation.z;
						# If the active gizmo axis is the Y axis...
						elif (active_gizmo_axis == "Y"):
							# Then reset current_rotation on the X and Z axis to the rotation stored in prior_rotation.
							current_rotation.x = prior_rotation.x;
							current_rotation.z = prior_rotation.z;
						# If the active gizmo axis is the Z axis...
						elif (active_gizmo_axis == "Z"):
							# Then reset current_rotation on the X and Y axis to the rotation stored in prior_rotation.
							current_rotation.x = prior_rotation.x;
							current_rotation.y = prior_rotation.y;
						
						# Set the rotation of the selected object to current_rotation.
						editor_viewport.selected_physics_object.rotation_degrees = current_rotation;
					
					# Set the rotation gizmo's rotation to the same rotation as the selected object!
					self.rotation_degrees = editor_viewport.selected_physics_object.rotation_degrees;


func update(var is_active):
	# Go through all of the children of the rotation gizmo.
	for child in get_children():
		# We are going to assume that all of the children of the rotation node have Editor_Gizmo_Collider assigned to them.
		# If the gizmo needs to be active...
		if (is_active == true):
			# Tell the gizmo collider to become active.
			child.activate();
		
		# If the does NOT need to be active...
		else:
			# Tell the gizmo collider to become deactive.
			child.deactivate();
	
	# Based on is_active, change the visiblity of the rotation gizmo.
	visible = is_active;


func axis_set(new_axis):
	# Set active_gizmo_axis to the passed in axis, new_axis.
	active_gizmo_axis = new_axis;


