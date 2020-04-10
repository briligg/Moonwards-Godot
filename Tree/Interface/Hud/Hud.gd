extends CanvasLayer
"""
	Hud Singleton Scene Script
"""

var _active: bool = false


func _ready() -> void:
	hide()


func show() -> void:
	for i in get_children():
		if i is Control:
			i.visible = true


func hide() -> void:
	for i in get_children():
		if i is Control:
			i.visible = false


func set_active(state: bool) -> void:
	_active = state
	
	if _active:
		show()
	else:
		hide()
