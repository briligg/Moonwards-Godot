extends Spatial

var camera setget set_camera, get_camera
var current setget set_current, get_current

func set_camera(value):
	#idk probably needs replacing and stuff, no need it that atm
	pass

func get_camera():
	return $Camera

func set_current(value):
	get_camera().current = value

func get_current():
	return get_camera().current
