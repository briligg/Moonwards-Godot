extends Viewport

# A variable to hold the Editor_Controller node.
var editor_controller;

# The collision layer that all of the gizmo objects are on.
# See (https://godotengine.org/qa/17896/collision-layer-and-masks-in-gdscript) for details on how
# to convert a collision layer into a integer.
const GIZMO_COLLISION_LAYER = 2;

# A exported NodePath to the TextureRect we want to display the contents of the viewport on.
export (NodePath) var path_to_texture;

# A exported NodePath to the Editor_Camera_Controller node.
export (NodePath) var path_to_editor_camera;
# A variable to hold the Editor_Camera_Controller node.
var editor_camera;
# A variable to hold the Gizmo_Camera node.
var gizmo_camera;

# A variable to hold whether the left mouse button is down or not.
var left_mouse_button_down = false;
# A variable to hold the currently selected physics object. This object can be any of the following: RigidBody, StaticBody, and KinematicBody.
var selected_physics_object;
# A variable to hold the physics layer(s) the selected physics object was on prior to selection.
var selected_object_physics_layer;

# A variable to hold the node that is holding all of the gizmos.
var gizmos_holder;
# A variable to hold the translate gizmo. (translate -> translation -> movement on the X, Y, and/or Z axes). 
var gizmo_translate;
# A variable to hold the rotation gizmo.
var gizmo_rotate;
# A variable to hold the scale gizmo.
var gizmo_scale;
# A variable to hold the select gizmo.
var gizmo_select;

# A variable to hold the currently active gizmo.
var current_gizmo;


func _ready():
	# Get the Editor_Contoller node and assign it to editor_controller.
	# 
	# NOTE: using get_parent assumes that the parent of this node is Editor_Controller.
	# Depending on your project, this may or may not be a safe assumption.
	editor_controller = get_parent();
	
	# Set the size of the viewport to the size of the root viewport. This will make the gizmo viewport have the exact same size
	# as the main game window.
	self.size = get_tree().root.size
	
	# Let two frames pass so we can make sure the viewport screen has been captured at least once.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	# Then assign the texture of the TextureRect node that we want to display the viewport to the texture stored within this viewport.
	get_node(path_to_texture).texture = get_texture();
	
	# Get the editor camera using path_to_editor_camera and assign it to editor_camera.
	editor_camera = get_node(path_to_editor_camera);
	# Connect the "physics_object_selected" signal to the physics_object_selected function.
	# We need this so we can properly update the gizmos when a object has been selected.
	editor_camera.connect("physics_object_selected", self, "physics_object_selected");
	
	# Get the gizmo camera and assign it to gizmo_camera. This will be the camera this viewport uses to render the gizmos.
	# We will also use this camera for raycasting.
	gizmo_camera = get_node("Gizmo_Camera");
	
	# Connect the "on_editor_mode_change" function to the on_editor_mode_change function so we can change the active gizmo when the editor mode changes.
	editor_controller.connect("on_editor_mode_change", self, "on_editor_mode_change");
	
	# Get the gizmo holder node and assign it to gizmos_holder.
	gizmos_holder = get_node("Gizmos");
	# Get the other gizmo nodes and assign them to the class variables respective to the gizmo.
	gizmo_translate = gizmos_holder.get_node("Translate");
	gizmo_rotate = gizmos_holder.get_node("Rotate");
	gizmo_scale = gizmos_holder.get_node("Scale");
	gizmo_select = gizmos_holder.get_node("Select");
	
	# Make the current gizmo the select gizmo by default.
	current_gizmo = gizmo_select;
	# Update all of the gizmos.
	update_gizmos();


func on_editor_mode_change():
	# When the editor mode changes, update the gizmos!
	update_gizmos();


func update_gizmos():
	# First, disable all of the gizmos.
	gizmo_translate.update(false);
	gizmo_rotate.update(false);
	gizmo_scale.update(false);
	gizmo_select.update(false);
	
	# Based on the current editor mode, change current_gizmo to the proper gizmo.
	if (editor_controller.editor_mode == "TRANSLATE"):
		current_gizmo = gizmo_translate;
	elif (editor_controller.editor_mode == "ROTATE"):
		current_gizmo = gizmo_rotate;
	elif (editor_controller.editor_mode == "SCALE"):
		current_gizmo = gizmo_scale;
	elif (editor_controller.editor_mode == "SELECT"):
		current_gizmo = gizmo_select;
	
	# If there is a selected object...
	if (selected_physics_object != null):
		# Tell the current gizmo to update/enable itself!
		current_gizmo.update(true);


func _process(delta):
	# If we have a gizmo camera...
	if (gizmo_camera != null):
		# Set the gizmo camera's global transform to the global transform of the view camera in editor_camera.
		# This will make both the gizmo camera and the view camera look at exactly the same space!
		gizmo_camera.global_transform = editor_camera.view_camera.global_transform;
	
	# If the size of the editor viewport is different than the main viewport...
	if (get_tree().root.size != self.size):
		# Make the two viewports have the same size!
		self.size = get_tree().root.size;
	
	# If there is a selected object...
	if (selected_physics_object != null):
		# Position the gizmo holder to the same position as the selected object so the gizmos are positioned at the center
		# of the selected object!
		gizmos_holder.global_transform.origin = selected_physics_object.global_transform.origin;


func _physics_process(delta):
	# If the left mouse button is pressed or held...
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		# Check to see if the left mouse button was just pressed or not by checking to see if left_mouse_button_down is false.
		if (left_mouse_button_down == false):
			# Set it to true so the following code is only called once!
			left_mouse_button_down = true;
			
			# If the current editor mode is NOT select...
			if (editor_controller.editor_mode != "SELECT"):
				# Then send out a editor raycast to interact with the current gizmo!
				send_editor_raycast();
	
	# If the left mouse button is not pressed or held...
	else:
		# Then reset left_mouse_button_down.
		left_mouse_button_down = false;


func send_editor_raycast():
	# Get the space state the world contained within THIS viewport.
	var space_state = world.direct_space_state;
	
	# Get the starting position and end position of the raycast we want to create.
	# See (https://docs.godotengine.org/en/3.0/tutorials/physics/ray-casting.html) for more details on how to raycast using a camera!
	var raycast_from = gizmo_camera.project_ray_origin(get_mouse_position())
	var raycast_to = raycast_from + gizmo_camera.project_ray_normal(get_mouse_position()) * 100;
	
	# Send out a raycast and store the results of the raycast into a new variable called result.
	# Note that we are passing in GIZMO_COLLISION_LAYER, so the raycast will only collide with objects on that layer!
	var result = space_state.intersect_ray(raycast_from, raycast_to, [self], GIZMO_COLLISION_LAYER);
	
	# If there is something stored within result...
	if (result.size() > 0):
		# Then we collided with a gizmo handle!
		# Set the axis of the currently selected gizmo to the axis stored within the physics body we collided with.
		current_gizmo.axis_set(result.collider.gizmo_axis);
	# If there is not something stored within result...
	else:
		# Then we did not collide with anything!
		# Set the axis of the currently selected gizmo to NONE.
		current_gizmo.axis_set("NONE");


func physics_object_selected(new_object):
	
	# If we already have a selected object...
	if (selected_physics_object != null):
		# Set the collision/physics layer of the selected object to the collision/physics layer we stored in
		# selected_object_physics_layer.
		selected_physics_object.collision_layer = selected_object_physics_layer;
		
		# If the selected physics object is a RigidBody...
		if (selected_physics_object is RigidBody):
			# Apply a very small impulse so the RigidBody so the RigidBody is not sleeping and will interact with
			# the physics world again. If we do not have this, it will just stay floating in the air until another
			# physics object collides with it.
			selected_physics_object.apply_impulse(Vector3(0,0,0), Vector3(0, 0.01, 0));
	
	# Assign selected_physics_object to the newly selected physics object.
	# NOTE: if no physics object was selected, then new_object will be null.
	selected_physics_object = new_object;
	
	# If a new object was selected...
	if (selected_physics_object != null):
		# Store its collision layer in a variable named selected_object_physics_layer so we can reapply it
		# when the object is no longer selected.
		selected_object_physics_layer = selected_physics_object.collision_layer;
		# Set the collision layer of the object to 0 so it is not on any layers and will not collide with anything.
		selected_physics_object.collision_layer = 0;
		
		# If the selected object is a RigidBody...
		if (selected_physics_object is RigidBody):
			# Make both the linear and angular velocity zero so it will not move while selected.
			selected_physics_object.linear_velocity = Vector3(0,0,0);
			selected_physics_object.angular_velocity = Vector3(0,0,0);
			# And make the RigidBody asleep so it will not be effected by gravity.
			selected_physics_object.sleeping = true;
		
		# Tell the current gizmo to update/enable itself.
		current_gizmo.update(true);
	
	# If selected_physics_object is null...
	else:
		# Then nothing is currently selected and so we should disable the current gizmo.
		current_gizmo.update(false);

