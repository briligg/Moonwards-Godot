extends Node

var Behaviors : Array = []
var Behavior_names : Array = []

func _ready() -> void:
	load_behaviors_in(OS.get_user_data_dir())
	#Loads User Defined Behaviors
	load_behaviors_in("res://SceneComponent/Actor/Humanoid/NPCs/DefaultBehaviors/")
	#Loads Default behaviors


func load_behaviors_in(path : String) -> void:
	var Dir = Directory.new()
	if Dir.open(path) == OK:
		Dir.list_dir_begin()
		var file_name : String = Dir.get_next()
		while file_name != "":
			if not Dir.current_is_dir():
				if file_name.ends_with(".jbt"):
					var BT = ConfigFile.new()
					BT.load(file_name)
					Behaviors.append(BT)
					Behavior_names.append(file_name.trim_suffix(".jbt"))
				else:
					print_debug("Found a file that is not a BT")
			else:
				load_behaviors_in(file_name)
			file_name = Dir.get_next()
	else: 
		print_debug("Error accessing ", path)
