extends VBoxContainer


func _ready() -> void :
	var button : Button
	button = $HBoxContainer_Apps_Tab/Button_NPCEditor
	button.connect("pressed", self, "_set_tab", [0])

func _set_tab(new_tab : int) -> void :
	$TabContainer.current_tab = new_tab
