extends VBoxContainer


#Change the submenu when the buttons are pressed.
func _ready() -> void :
	var par : Control = get_parent()
	var button : Button
	button = get_node("GotoApps")
	button.connect("pressed", par, "change_submenu_by_name", [par.APPS])
	
	button = get_node("GotoEvent")
	button.connect("pressed", par, "change_submenu_by_name", [par.EVENTS])
	
	button = get_node("GotoMap")
	button.connect("pressed", par, "change_submenu_by_name", [par.MAP])
	
	button = get_node("GotoRecording")
	button.connect("pressed", par, "change_submenu_by_name", [par.RECORD_SCREEN])
