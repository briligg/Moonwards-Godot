extends Panel

onready var back : TextureButton = $Back


func _back_pressed() -> void :
	if not $VBoxContainer.visible :
		controls_pressed()
		$Anim.play_backwards("Controls")
		$AnimVisibility.play("ShowMainSubmenu")

#Listen for back being pressed so we can hide it.
func _ready() -> void :
	back.connect("pressed", self, "_back_pressed")

func controls_pressed() -> void :
	var vbox : VBoxContainer = $VBoxContainer
	vbox.visible = !vbox.visible
	var controls : Control = $Controls
	
	#Showing Controls menu.
	if not controls.visible :
		$Anim.play("Controls")
		$AnimVisibility.play("ShowControls")

func hide_panel() -> void :
	hide()

func toggle_menu_panel() -> void :
	visible = !visible



