extends Node
# Common helper functions

var Enum = EnumHelper.new()

var is_capture_mode : bool = false

func _input(event):
	if event.is_action_pressed("mainmenu_toggle"):
		if is_capture_mode:
			capture_mouse(false)
		else:
			capture_mouse(true)

func capture_mouse(capture_mouse : bool) -> void :
	if capture_mouse == true :
		is_capture_mode = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Signals.Menus.emit_signal("set_mouse_to_captured", true)
	
	else :
		is_capture_mode = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Signals.Menus.emit_signal("set_mouse_to_captured", false)
