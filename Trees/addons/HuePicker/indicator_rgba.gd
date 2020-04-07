extends PanelContainer

onready var pop = $Pop
onready var Color_picker = $Pop/ColorPicker

func _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == BUTTON_LEFT:  #MouseDown
			Color_picker.color = $'../..'.color
			pop.rect_position = rect_global_position
			pop.popup()
