extends RichTextLabel


func _ready() -> void :
	var save_text : String = ""
	for string in Helpers.editable_actions :
		save_text += "%s: %s\n" % [string, Helpers.get_action_string(string)]
	
	text = save_text
