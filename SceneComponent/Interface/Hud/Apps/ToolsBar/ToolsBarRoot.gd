extends PanelContainer


func _ready() -> void :
	var button = $VBoxContainer/HBoxContainer_Dynamic/VBoxContainer5/MarginContainer/Button_NPC
	button.connect("pressed", self, "pressed", ["NPCApp"])

func pressed(app_name : String) -> void :
	get_parent().change_app(app_name)
