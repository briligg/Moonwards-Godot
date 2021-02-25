extends Control


func _defaults_pressed() -> void :
	$DefaultsPopup.popup_centered()

func _ready() -> void :
	var button : Button = $HBox/Sub1/DefaultControls
	button.connect("pressed", self, "_defaults_pressed")
	
	#Listen for confirmation from the default buttons.
	$DefaultsPopup.connect("confirmed", self, "set_to_default")

func save_pressed():
	Helpers.save_user_file()
	
func set_to_default() -> void :
	$DefaultsPopup.hide()
	
	InputMap.load_from_globals()
	
	#Go through all control buttons and set them to default.
	for child in $HBox/Sub1.get_children() :
		if child is HBoxContainer :
			child.update_labels()
	for child in $HBox/Sub2.get_children() :
		if child is HBoxContainer :
			child.update_labels()
	
	save_pressed()
