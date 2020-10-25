extends Button


func _pressed() -> void :
	var par : Control = get_node("../..")
	par.change_submenu_by_name(par.APPS)
