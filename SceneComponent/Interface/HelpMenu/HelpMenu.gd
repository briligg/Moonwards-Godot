extends Control


const APPS : String = "AppsHelp"
const START : String = "InitialMenu"

onready var start : VBoxContainer = get_node(START)


#Keeps track of the current submenu.
onready var current_submenu : Control = start


#Return to the starting menu.
func back_to_start() -> void :
	#Make all children node disappear.
	for child in get_children() :
		if child.has_method("hide") :
			child.hide()
	
	#Go back to the starting menu.
	start.show()

func change_submenu(new_submenu : Control) -> void :
	
	
	current_submenu.hide()
	current_submenu = new_submenu
	new_submenu.show()
	
	#Bring up the go back button if we are not at start.
	if new_submenu != start :
		get_node("../..").display_back_button(true)
	else : 
		get_node("../..").display_back_button(false)
	
func change_submenu_by_name(submenu_name : String) -> void :
	change_submenu(get_node(submenu_name))




