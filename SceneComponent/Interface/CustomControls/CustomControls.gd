extends Tabs


func _defaults_pressed() -> void :
	InputMap.load_from_globals()
	
	#Go through all control buttons and set them to default.
	for child in $ButtonList/HBox/Sub1.get_children() :
		if child is HBoxContainer :
			child.update_labels()
	for child in $ButtonList/HBox/Sub2.get_children() :
		if child is HBoxContainer :
			child.update_labels()
	
	_on_Button_pressed()

func _on_Button_pressed():
	Helpers.save_user_file()

func _ready() -> void :
	var button : Button = $ButtonList/HBox/Sub1/DefaultControls
	button.connect("pressed", self, "_defaults_pressed")
