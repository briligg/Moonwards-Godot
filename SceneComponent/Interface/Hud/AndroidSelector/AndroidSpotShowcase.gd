extends Panel




func _android_selected(android : ActorEntity) -> void :
	get_parent().android_selected(android)

#Called when an Android has control taken from it.
func _hide_button(button) -> void :
	button.hide()

#When a player leaves control of the Android.
func _show_button(button) -> void :
	button.show()

func add_spot(android : ActorEntity, text : String, spatial : Spatial) -> void :
	var button : Button = Button.new()
	button.text = text
	$List.add_child(button)
	button.connect("pressed", self, "_android_selected", [android])
	
	#Listen for when the spatial changes availability.
	spatial.connect("android_taken", self, "_hide_button", [button])
	spatial.connect("android_returned", self, "_show_button", [button])
