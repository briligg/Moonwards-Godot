extends PanelContainer

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == BUTTON_LEFT:  #MouseDown
			$Pop/ColorPicker.color = $'../..'.color
			$Pop.rect_position = rect_global_position
			$Pop.popup()
