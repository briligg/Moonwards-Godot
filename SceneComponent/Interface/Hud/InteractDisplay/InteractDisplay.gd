extends Label
"""
 Show to the user the current possible interaction.
"""

func _hide_interact_info() -> void :
	hide()

func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.INTERACTABLE_DISPLAY_SHOWN, self, "_show_interact_info")
	Signals.Hud.connect(Signals.Hud.INTERACTABLE_DISPLAY_HIDDEN, self, "_hide_interact_info")

#Let the user know what interaction is possible.
func _show_interact_info(interactable_title : String) -> void :
	#Hide the menu if there are no Interactables to interact with.
	text = "Press " 
	text += OS.get_scancode_string(InputMap.get_action_list("use")[0].scancode)
	text += " to show InteractsMenu.\n"
	text += "Press " + OS.get_scancode_string(InputMap.get_action_list("interact_with_closest")[0].scancode)
	text += " to interact with " + interactable_title
	show()
