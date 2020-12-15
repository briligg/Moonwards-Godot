extends RichTextLabel

onready var scene_root : Panel = get_node("../../../..")

var original_text : String = ""

func _ready() -> void :
	original_text = text
	format_text()
	
	scene_root.connect("visibility_changed", self, "_update")

func _update() -> void :
	if not scene_root.visible :
		return
	
	format_text()

func format_text() -> void :
	var array : Array = [
		Helpers.get_action_string("toggle_first_person"),
		Helpers.get_action_string("move_forwards"),
		Helpers.get_action_string("move_backwards"),
		Helpers.get_action_string("move_left"),
		Helpers.get_action_string("move_right"),
		Helpers.get_action_string("jump"),
		Helpers.get_action_string("toggle_fly"),
		Helpers.get_action_string("fly_up"),
		Helpers.get_action_string("fly_down"),
		Helpers.get_action_string("toggle_camera_fly"),
		Helpers.get_action_string("fly_up"),
		Helpers.get_action_string("fly_down"),
		Helpers.get_action_string("use"), #Interacts Menu
		Helpers.get_action_string("chat_toggle_size"),
		Helpers.get_action_string("chat_page_up"),
		Helpers.get_action_string("chat_page_down")
	]
	
	text = original_text % array
