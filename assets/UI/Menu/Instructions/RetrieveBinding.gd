extends Control

func _ready() -> void:
	var text_to_place = ""
	var key_names = self.name.split(" ")
	
	for key_name_index in key_names.size():
		var key_name = key_names[key_name_index]
		
		var combination_names = key_name.split("+")
		for combination_name_index in combination_names.size():
			var button_name = combination_names[combination_name_index]
			text_to_place += _get_input_names(button_name)
			
			if combination_name_index !=  combination_names.size() - 1:
				text_to_place += " + "
		
		if key_name_index !=  key_names.size() - 1:
			text_to_place += " and "
	
	$control.text = text_to_place

func _get_input_names(var button_name) -> String:
	var result = ""
	var actions = InputMap.get_action_list(button_name)
	
	for id_index in actions.size():
		var id = actions[id_index]
		
		if id  is InputEventKey:
			result += OS.get_scancode_string(id .scancode)
		elif id is InputEventMouseButton:
			if id.button_index == BUTTON_WHEEL_DOWN:
				result += "Wheel Down"
			elif id.button_index == BUTTON_WHEEL_UP:
				result += "Wheel Up"
		if actions.find(id) != actions.size() - 1:
			result += " and "
	
	return result