extends VBoxContainer


#Quit if the player presses quit. Go to Destination if player presses the other button.
func _ready() -> void :
	var button : Button = $HBoxContainer/Button_Quit_Yes
	button.connect("pressed", get_tree(), "quit")
	
	#Switch tab if cancel is pressed.
	var main_control : Control = get_node("../..")
	button = $HBoxContainer/Button_Quit_No
	button.connect("pressed", main_control, "show_tab", ["Destination"])
