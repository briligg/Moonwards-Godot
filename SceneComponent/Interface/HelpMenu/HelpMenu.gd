extends Control


onready var start : VBoxContainer = $InitialMenu


#Return to the starting menu.
func back_to_start() -> void :
	#Make all children node disappear.
	for child in get_children() :
		if child.has_method("hide") :
			child.hide()
	
	#Go back to the starting menu.
	start.show()
