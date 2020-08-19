tool
extends FileDialog

func _enter_tree():
	if not Engine.editor_hint:
		access = FileDialog.ACCESS_USERDATA
		var Dir = Directory.new()
		if not Dir.dir_exists("user://NPCDialogs/"):
			Dir.make_dir("user://NPCDialogs/")
		
		current_dir = "user://NPCDialogs/"
		current_path = "user://NPCDialogs/"

func set_open():
	mode = FileDialog.MODE_OPEN_FILE 

func set_save():
	mode = FileDialog.MODE_SAVE_FILE
