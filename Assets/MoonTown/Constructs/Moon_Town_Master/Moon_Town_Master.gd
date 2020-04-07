"""
Tasked with handling any small task related to getting the world setup.
"""
extends Spatial


func _ready() -> void :
	#Capture the mouse and hide the menus.
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	MainMenu.hide()
	PauseMenu.hide()
