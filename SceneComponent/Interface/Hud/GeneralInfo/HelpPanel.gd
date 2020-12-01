extends Panel

onready var help_menu : Control = $Alignment/HelpMenu
onready var back_button : TextureButton = $Alignment/TopSection/Label/BackButton
onready var close : TextureButton = get_node("Alignment/TopSection/Label/Close")

#Listen to back button presses.
func _ready() -> void :
	back_button.connect("pressed", self, "back_pressed")
	
	#Close when the close button is pressed.
	close.connect("pressed", self, "toggle_help_menu")

func back_pressed() -> void :
	var menus : Control = $Alignment/HelpMenu
	menus.change_submenu_by_name(menus.START)

#Hide the panel. Clean up anything that needs cleaning up.
func hide_panel() -> void :
	help_menu.back_to_start()
	back_button.hide()
	hide()
	
	

#Toggle the help menu on or off.
func toggle_help_menu() -> void :
	visible = !visible

func display_back_button(become_visible : bool) -> void :
	back_button.visible = become_visible
