extends VBoxContainer


func _ready() -> void :
	
	
	var button : Button
	button = $ButtonGrid/NpcEditor
	button.connect("pressed", get_node("../../.."), "fullscreen", ["NPCEditor"])
