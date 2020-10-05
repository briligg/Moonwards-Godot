extends Control


#Go back to the previous menu.
func _close_pressed() -> void :
	get_parent().revert_active_app()

#Listen for the close button to be pressed.
func _ready() -> void :
	$Close.connect("pressed", self, "_close_pressed")
