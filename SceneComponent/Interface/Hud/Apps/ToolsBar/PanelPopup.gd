extends Button


func _pressed() -> void :
	get_tree().call_group("hud_general_info", "toggle_menu_panel")
