extends Node
# Common helper functions

var Enum = EnumHelper.new()

#### Temporary for testing
var is_capture_mode: float = true
func _input(event):
	if event.is_action_pressed("mainmenu_toggle"):
		if is_capture_mode:
			is_capture_mode = !is_capture_mode
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			is_capture_mode = !is_capture_mode
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
