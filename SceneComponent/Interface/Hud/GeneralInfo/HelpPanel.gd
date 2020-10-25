extends Panel


#Listen to back button presses.
func _ready() -> void :
	var back : TextureButton = $Alignment/TopSection/Label/BackButton
	
	back.connect("pressed", self, "back_pressed")

func back_pressed() -> void :
	var menus : Control = $Alignment/HelpMenu
	menus.change_submenu_by_name(menus.START)

#Hide the panel. Clean up anything that needs cleaning up.
func hide_panel() -> void :
	$HelpMenu.back_to_start()
	hide()

#Toggle the help menu on or off.
func toggle_help_menu() -> void :
	visible = !visible

func display_back_button(become_visible : bool) -> void :
	$Alignment/TopSection/Label/BackButton.visible = become_visible
