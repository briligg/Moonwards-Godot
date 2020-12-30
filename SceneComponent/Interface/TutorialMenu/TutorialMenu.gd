extends Panel

#I am part of group TutorialMenu

#This is the file I check to see if people want me to open at start.
var file : File = File.new()

const POPUP_AT_START : String = "POPUP AT START"
const DO_NOT_POPUP : String = "DO NOT POPUP AT START"

#Close pressed.
func _close() -> void :
	visible = false
	
	Hud.show(Hud.flags.RelevantToTutorial)

func _popup_at_start_set(boolean : bool) -> void :
	if boolean :
		file.open(Helpers.SAVE_FOLDER+"not_first_time.txt", file.WRITE)
		file.store_line(POPUP_AT_START)
		file.close()
	else :
		file.open(Helpers.SAVE_FOLDER+"not_first_time.txt", file.WRITE)
		file.store_line(DO_NOT_POPUP)
		file.close()

#Close the tutorial menu if closed is pressed.
func _ready() -> void :
	$Close.connect("pressed", self, "_close")
	$PopupAtStart.connect("toggled", self, "_popup_at_start_set")
	
	#Check to see if this is the user's first time running the game.
	if file.file_exists(Helpers.SAVE_FOLDER+"not_first_time.txt") :
		file.open(Helpers.SAVE_FOLDER+"not_first_time.txt", file.READ)
		if file.get_line() == DO_NOT_POPUP :
			$PopupAtStart.pressed = false
			return
		file.close()
		
	
	#This is the user's first time running Moonwards. Bring up the Tutorial menu.
	toggle()

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
