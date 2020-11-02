extends Control


onready var tabs : TabContainer = $TabContainer


#Connect all the buttons so that they show the correct parent.
func _ready() -> void :
	var button : Button
	button = $TRButtons/Button_Settings_Icon
	button.connect("pressed", self, "show_tab", ["Settings"])
	
	button = $TRButtons/Button_About_Icon
	button.connect("pressed", self, "show_tab", ["About"])
	
	button = $TRButtons/Button_Quit_Icon
	button.connect("pressed", self, "show_tab", ["Quit"])
	
	button = $TabButtons/Button_Destination
	button.connect("pressed", self, "show_tab", ["Destination"])
	button.call_deferred("grab_focus") #Make Destination button green at start
	
	button = $TabButtons/Button_Avatar
	button.connect("pressed", self, "show_tab", ["Avatar"])
	
	button = $TabButtons/Button_Apps
	button.connect("pressed", self, "show_tab", ["Apps"])


func show_tab(tab_name : String) -> void :
	#If this assert fails the tab_name must be invalid.
	assert(tabs.has_node(tab_name))
	tabs.current_tab = tabs.get_node(tab_name).get_position_in_parent()
