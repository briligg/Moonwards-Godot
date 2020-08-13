extends FileDialog

func set_project():
	access = ACCESS_RESOURCES
	current_path = "res://"

func set_user():
	access = ACCESS_USERDATA
	current_path = "user://"
