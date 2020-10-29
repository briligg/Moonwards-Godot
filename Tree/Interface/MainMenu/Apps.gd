extends VBoxContainer


func _ready() -> void :
	var button : Button
	button = $TabContainer/ButtonGrid/NpcEditor
	button.connect("pressed", self, "_set_tab", [1])
	
	#Listen for when the main tab has changed
	get_node("../..").connect("tab_changed", self, "_reset_tab")

#Set tab back to the beginning.
func _reset_tab(tab_name : String) -> void :
	_set_tab(0)

func _set_tab(new_tab : int) -> void :
	$TabContainer.current_tab = new_tab
