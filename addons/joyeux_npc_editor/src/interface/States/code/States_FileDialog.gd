tool
extends FileDialog

func _enter_tree():
	if not Engine.editor_hint:
		access = FileDialog.ACCESS_USERDATA
		var Dir = Directory.new()
		if not Dir.dir_exists("user://NPCConfigs/"):
			Dir.make_dir("user://NPCConfigs/")
		
		current_dir = "user://NPCConfigs/"
		current_path = "user://NPCConfigs/"

func set_open():
	mode = FileDialog.MODE_OPEN_FILE 

func set_save():
	mode = FileDialog.MODE_SAVE_FILE
