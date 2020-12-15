extends VBoxContainer

#Store the original string so that we know where the %s is.
var original_text : String
var original_text_two : String

func _ready() -> void :
	original_text  = $Text.text
	original_text_two = $Text2.text
	format_text()

func format_text() -> void :
	var array : Array = [
		Helpers.get_action_string("move_forwards"),
		Helpers.get_action_string("move_left"),
		Helpers.get_action_string("move_backwards"),
		Helpers.get_action_string("move_right"),
		Helpers.get_action_string("jump"),
		Helpers.get_action_string("mouse_toggle")
	]
	$Text.text = original_text % array
	
	$Text2.text = original_text_two % Helpers.get_action_string("toggle_first_person")
