tool
extends Control
class_name Slide, "res://Assets/Icons/Slide.svg"


func get_class(): return "Slide"


func is_class(class_string) -> bool: 
	if class_string.match("Slide"):
		return true
	return false
