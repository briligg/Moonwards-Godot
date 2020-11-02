extends Label
"""
 Show to the user the current possible interaction.
"""

func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.INTERACTABLE_ENTERED_REACH, self, "show_interact_info")

#Let the user know what interaction is possible.
func show_interact_info(new_interactable : Interactable) -> void :
	#Hide the menu if there are no Interactables to interact with.
	if new_interactable == null :
		hide()
		return
	
	text = "Press " 
	text += OS.get_scancode_string(InputMap.get_action_list("use")[0].scancode)
	text += " to show InteractsMenu.\n"
	text += "Press " + OS.get_scancode_string(InputMap.get_action_list("interact_with_closest")[0].scancode)
	text += " to interact with " + new_interactable.title
	show()
