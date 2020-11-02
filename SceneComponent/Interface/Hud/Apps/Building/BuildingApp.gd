extends PanelContainer


#Listen to when we should close the BuildingApp.
func _ready() -> void :
	var exit_button : Button
	exit_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/MarginContainer2/Button_Exit
	exit_button.connect("pressed", self, "exit")

func exit() -> void :
	get_parent().revert_active_app()
