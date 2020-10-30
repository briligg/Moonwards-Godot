extends VBoxContainer


func _main_menu_pressed() -> void :
	Scene.change_scene_to_async(Scene.main_menu)

func _quit_pressed() -> void :
	get_tree().quit()

func _ready() -> void :
	$MainMenu.connect("pressed", self, "_main_menu_pressed")
	$Quit.connect("pressed", self, "_quit_pressed") 
