"""
 This shows the chat history.
 It is where the display's formatting takes place.
"""
extends RichTextLabel


func add_message(new_message : String ) -> void :
	newline()
	
	#Format the text so that is displays the username along with it.
	var colon_position : int = new_message.find(":")
	new_message = new_message.insert(colon_position + 1, "[/color]")
	new_message = new_message.insert(0, "[color=#00FF1A]")
	
	#warning-ignore:return_value_discarded
	append_bbcode(new_message)
