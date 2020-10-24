extends Panel


#Hide the panel. Clean up anything that needs cleaning up.
func hide_panel() -> void :
	hide()

#Toggle the help menu on or off.
func toggle_help_menu() -> void :
	visible = !visible
