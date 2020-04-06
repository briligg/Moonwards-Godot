extends CanvasLayer
"""
	PauseMenu Singleton Scene Script
"""

onready var tabs: TabContainer = $"H/T"


var _can_open: bool = false
var _open: bool = false


func _ready() -> void:
	hide(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mainmenu_toggle"):
		#Do nothing if we are not allowed to open.
		if _can_open == false :
			return
		
		if _open:
			hide()
		else:
			show()


func set_openable(state: bool) -> void:
	_can_open = state


func is_open() -> bool:
	return _open


func show() -> void:
	_open = true
	for i in get_children():
		if i is Control:
			i.visible = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func hide(change_mouse_mode: bool = true) -> void:
	_open = false
	for i in get_children():
		if i is Control:
			i.visible = false
	
	if change_mouse_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_bContinue_pressed() -> void:
	hide()


func _on_bOptions_pressed() -> void:
	tabs.current_tab = 1


func _on_bAbout_pressed() -> void:
	tabs.current_tab = 2


func _on_bQuit_pressed() -> void:
	# TODO: Disconnect from server first
	get_tree().quit()
