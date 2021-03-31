extends Panel



func _android_selected(android : ActorEntity) -> void :
	get_parent().android_selected(android)

func add_spot(android : ActorEntity, text : String) -> void :
	var button : Button = Button.new()
	button.text = text
	$List.add_child(button)
	button.connect("pressed", self, "_android_selected", [android])
