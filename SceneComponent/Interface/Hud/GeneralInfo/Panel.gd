extends Panel

onready var back : TextureButton = $Back


func _back_pressed() -> void :
	if not $VBoxContainer.visible :
		back.hide()
		controls_pressed()

#Listen for back being pressed so we can hide it.
func _ready() -> void :
	back.connect("pressed", self, "_back_pressed")

func controls_pressed() -> void :
	var vbox : VBoxContainer = $VBoxContainer
	vbox.visible = !vbox.visible
	var controls : Tabs = $Controls
	controls.visible = !controls.visible
	
	#Let the player go back if they need to.
	if controls.visible :
		back.show()

func hide_panel() -> void :
	hide()

func toggle_menu_panel() -> void :
	visible = !visible



