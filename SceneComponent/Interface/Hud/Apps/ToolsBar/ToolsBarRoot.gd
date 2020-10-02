extends PanelContainer


func _ready() -> void :
	var button = $VBoxContainer/HBoxContainer_Dynamic/VBoxContainer5/MarginContainer/Button_NPC
	button.connect("pressed", self, "pressed", ["NPCApp", true])
	
	button = $VBoxContainer/HBoxContainer_Dynamic/VBoxContainer2/MarginContainer/Button_Build
	button.connect("pressed", self, "pressed", ["BuildingApp", false])

func pressed(app_name : String, blur_background : bool) -> void :
	get_parent().change_app(app_name, blur_background)
