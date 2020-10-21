extends VBoxContainer

#The tab container that we will be switching between.
onready var tabs : TabContainer = $TabContainer

func _ready() -> void :
	var button : Button
	button = $HBoxContainer_Settings_Tab/Button_Sett_Visual
	button.connect("pressed", self, "_set_tab", [0])
	
	button = $HBoxContainer_Settings_Tab/Button_Sett_Controls
	button.connect("pressed", self, "_set_tab", [1])

func _set_tab(tab_int : int) -> void :
	tabs.current_tab = tab_int
