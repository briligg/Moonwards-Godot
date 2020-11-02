extends CanvasLayer


var _active: bool = false


func show() -> void:
	for child in get_children():
		if child is Control:
			child.visible = true

func hide() -> void:
	for child in get_children():
		if child is Control:
			child.visible = false

func set_active(state: bool) -> void:
	_active = state
	
	if _active:
		show()
	else:
		hide()
