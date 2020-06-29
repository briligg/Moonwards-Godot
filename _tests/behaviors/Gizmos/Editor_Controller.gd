extends Spatial

# NOTE: This node is used to transfer data between the UI and the other gizmo/editor nodes, and is used to store
# data we will need in multiple of the editor/gizmo nodes.

# A signal that we will emit when the UI has changed the editor mode.
signal on_editor_mode_change();

# A string to hold the current mode the editor is in. This changes which gizmo is used.
export (String, "SELECT", "TRANSLATE", "ROTATE", "SCALE") var editor_mode;

# A boolean to hold whether the camera is in free look mode. This is so we know whether the camera view is moving
# and so we should ignore mouse clicks.
var is_in_freelook_mode = false;

# A function that will change the gizmo mode the editor is using.
func change_editor_mode(new_mode):
	# Assign editor_mode to the passed in mode, new_mode.
	editor_mode = new_mode;
	# Then emit the on_editor_mode_change signal so anything connected to the signal knows the mode has changed.
	emit_signal("on_editor_mode_change");

func _input(event):
	# NOTE: Because Viewport nodes cannot process input events on their own, as generally you need to make adjustments, we
	# have to pass in all of the inputs events to the viewport here.
	# 
	# We do not need to do any additional processing because the
	# editor viewport is exactly the same size and position as the root/main viewport, so we can just pass the input events along.
	get_node("Editor_Viewport").input(event);
