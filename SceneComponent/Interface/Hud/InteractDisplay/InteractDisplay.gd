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
func _show_interact_info(interactable_description : String, uses_menu_only : bool) -> void :
	show()
	
	#If you cannot interact via a Ray Cast then 
	#let the player know to bring up the menu.
	if uses_menu_only :
		text = "Press " 
		text += OS.get_scancode_string(InputMap.get_action_list("use")[0].scancode)
		text += " to toggle InteractsMenu."
		return
	
	text = "left click to " + interactable_description
