extends Reference
class_name MenuSignals

### Until we or godot implements proper class_name handling
const name = "Menus"


const SET_MOUSE_TO_CAPTURED : String = "set_mouse_to_captured"

#Called when the mouse is set to either captured (true) or anything else (false)
signal set_mouse_to_captured(is_captured_bool)
