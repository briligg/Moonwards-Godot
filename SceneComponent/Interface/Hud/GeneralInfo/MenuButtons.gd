extends VBoxContainer


func _main_menu_pressed() -> void :
	Network.network_instance.disconnect_instance()
	Network.network_instance.world.queue_free()
	Network.network_instance.queue_free()
	yield(get_tree(), "physics_frame")
	Scene.change_scene_to_async(Scene.main_menu)

func _quit_pressed() -> void :
	get_tree().quit()

func _ready() -> void :
	$Controls.connect("pressed", get_parent(), "controls_pressed")
	$MainMenu.connect("pressed", self, "_main_menu_pressed")
	$Quit.connect("pressed", self, "_quit_pressed") 
