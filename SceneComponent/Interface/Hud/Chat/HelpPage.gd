extends RichTextLabel


func _ready() -> void :
	connect("visibility_changed", self, "_update_text")

#The player has brought up the Help Menu. Update text to reflect
#keyboard input.
func _update_text() -> void :
	if not visible :
		return
	
	text %= [Helpers.get_action_string("chat_toggle_size")]
