"""
 A popup for text that showcases short but interesting information.
 Use get_tree().call_group( "ExtraInfoDisplay", "popup", title_text, information_text)
 to activate it.
"""
extends PanelContainer


func _input( event : InputEvent ) -> void :
	#This only starts when popup has been called.
	#Hide the popup when the player has confirmed they have
	#read the display.
	if event.is_action_pressed( "hide_extra_info_display" ) :
		set_process_input( false )
		hide()
		return

func _ready() -> void :
	#I don't want to process input until after popup has been called.
	set_process_input( false )

func popup( title_text : String, information_text : String ) -> void :
	#Make the appropriate nodes have their needed text.
	$Holder/Title.text = title_text
	$Holder/Info.text = information_text
	
	#Make sure the text detailing what button to press to hide the display is correct.
	var hide_button_text = "Press "
	hide_button_text += "'" + OS.get_scancode_string(InputMap.get_action_list("hide_extra_info_display")[0].scancode )
	hide_button_text += "' to hide this display"
	$Holder/HideButton.text = hide_button_text
	
	#Make the display actually show itself.
	show()
	
	#Start listening for the player to confirm that they read the display.
	set_process_input( true )
