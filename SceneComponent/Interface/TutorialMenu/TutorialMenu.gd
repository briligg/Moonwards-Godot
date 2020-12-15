extends Panel

#I am part of group TutorialMenu

#Close pressed.
func _close() -> void :
	visible = false
	
	Hud.show(Hud.flags.RelevantToTutorial)

#Close the tutorial menu if closed is pressed.
func _ready() -> void :
	$Close.connect("pressed", self, "_close")
	
	#Check to see if this is the user's first time running the game.
	var file : File = File.new()
	if file.file_exists(Helpers.SAVE_FOLDER+"not_first_time.txt") :
		return
	
	#This is the user's first time running Moonwards. Bring up the Tutorial menu.
	toggle()
	
	#Store that the player has played the game before.
	file.open(Helpers.SAVE_FOLDER+"not_first_time.txt", file.WRITE)
	file.store_line("This file being present and named not_first_time.txt keeps Tutorial Menu from auto popup.")
	file.close()

#Toggles the Tutorial Menus visibility.
func toggle() -> void :
	visible = !visible
	
	#If we are now visible. Hide all other menus.
	if visible :
		Hud.hide(Hud.flags.RelevantToTutorial)
		
		#Update the text to reflect actual controls.
		$VWithTheme.call_deferred("format_text")
	
	#Bring up the other menus if I am being hidden.
	else :
		Hud.show(Hud.flags.RelevantToTutorial)
