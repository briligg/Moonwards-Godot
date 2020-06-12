extends Label
"""
 Show to the user the current possible interaction.
"""

func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.INTERACT_POSSIBLE, self, "show_interact_info")
	Signals.Hud.connect(Signals.Hud.INTERACT_BECAME_IMPOSSIBLE, self, "interact_became_impossible")

#Let the user know what interaction is possible.
func show_interact_info( display_string : String ) -> void :
	text = "Press " 
	text += OS.get_scancode_string(InputMap.get_action_list( "use" )[0].scancode)
	text += " " + display_string
	show()

func interact_became_impossible() -> void :
	hide()
