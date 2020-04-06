extends Label
"""
 For displaying to the player that they can interact with an object.
 Is meant to be called from the group InteractDisplay with the method
 show_interact_info. Use hide() when you no longer want me visible.
"""


func show_interact_info( display_string : String ) -> void :
	#Set my text to what is shown.
	text = "Press " 
	text += OS.get_scancode_string(InputMap.get_action_list( "use" )[0].scancode )
	text += " " + display_string
	show()
	
	#TODO: Configure me so that I am displayed correctly for
	#whatever resolution we are at.
