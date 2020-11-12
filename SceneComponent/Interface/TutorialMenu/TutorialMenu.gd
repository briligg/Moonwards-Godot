extends Panel

#I am part of group TutorialMenu


#Close pressed.
func _close() -> void :
	visible = false
	
	Hud.show(Hud.flags.AllExceptTutorial)

#Close the tutorial menu if closed is pressed.
func _ready() -> void :
	$Close.connect("pressed", self, "_close")

#Toggles the Tutorial Menus visibility.
func toggle() -> void :
	visible = !visible
	
	#If we are now visible. Hide all other menus.
	if visible :
		Hud.hide(Hud.flags.AllExceptTutorial)
	
	#Bring up the other menus if I am being hidden.
	else :
		Hud.show(Hud.flags.AllExceptTutorial)
