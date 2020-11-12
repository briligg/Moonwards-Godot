extends Panel

#I am part of group TutorialMenu


#Close pressed.
func _close() -> void :
	visible = false

#Close the tutorial menu if closed is pressed.
func _ready() -> void :
	$Close.connect("pressed", self, "_close")

#Toggles the Tutorial Menus visibility.
func toggle() -> void :
	visible = !visible
