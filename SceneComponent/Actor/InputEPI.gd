extends EPIBase
class_name InputEPI

signal jump_pressed(force_float)
const JUMP_PRESSED = "jump_pressed"

var input : Vector3 = Vector3.ZERO setget set_input, get_input

#Where the camera is pointing.
var look_dir : Vector3 = Vector3.FORWARD setget set_look_dir, get_look_dir

func get_look_dir() -> Vector3 :
	return look_dir

func get_input() -> Vector3 :
	return input

#Input is jump. Force float is value between 0 and 1 for how long jump was held.
func jump(force_float : float) -> void :
	force_float = clamp(force_float, 0, 1) #Prevent values outside range.
	emit_signal(JUMP_PRESSED, force_float)

func set_look_dir(new_look_dir : Vector3) -> void :
	look_dir = new_look_dir

func set_input(new_input : Vector3) -> void :
	input = new_input
