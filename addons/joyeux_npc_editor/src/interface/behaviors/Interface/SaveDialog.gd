tool
extends FileDialog

export(String, DIR) var Start_path

func _enter_tree():
	if not Engine.editor_hint:
		access = FileDialog.ACCESS_USERDATA
		current_dir = "user://behaviors/"
		current_path = "user://behaviors/"
