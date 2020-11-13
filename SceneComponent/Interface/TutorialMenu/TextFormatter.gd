extends VBoxContainer


func _ready() -> void :
	$Text.text = $Text.text % [
		Helpers.get_action_string("move_forwards"),
		Helpers.get_action_string("move_left"),
		Helpers.get_action_string("move_backwards"),
		Helpers.get_action_string("move_right"),
		Helpers.get_action_string("jump"),
		Helpers.get_action_string("toggle_first_person"),
		Helpers.get_action_string("mouse_toggle"),
		Helpers.get_action_string("interact_with_closest")
	]
