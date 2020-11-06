extends Control

signal closed()

#Go back to the previous menu.
func _close_pressed() -> void :
	if get_parent().has_method("revert_active_app") :
		get_parent().revert_active_app()
	
	emit_signal("closed")

#Listen for the close button to be pressed.
func _ready() -> void :
	$Close.connect("pressed", self, "_close_pressed")
