extends VSplitContainer

var current_idx = 0
var Behaviors : Array = []
var Behavior_names : Array = []
var Behavior_routes : Array = []
var SaveFile : ConfigFile = ConfigFile.new()


onready var BehaviorList : ItemList = $ViewMenuSplit/Container/ScrollContainer/Behaviors
onready var BehaviorMenu : PopupMenu = $ViewMenuSplit/StatesGraphEdit/States
onready var Graph : GraphEdit = $ViewMenuSplit/StatesGraphEdit

func _ready() -> void:
	var dir = Directory.new()
	dir.open(OS.get_user_data_dir())
	dir.make_dir_recursive("behaviors")
	load_behaviors_in(OS.get_user_data_dir()+"/behaviors")
	#Loads User Defined Behaviors
	load_behaviors_in("res://SceneComponent/Actor/Humanoid/NPCs/DefaultBehaviors")
	#Loads Default behaviors
	list_behaviors()
	
func save_states(file : String):
	#First we save the routes to the nodes used in the machine
	var names : Array = Graph.get_unique_nodes()
	for _name in names:
		var idx : int = Behavior_names.find(_name)
		SaveFile.set_value("node_routes", _name, Behavior_routes[idx])
	save_SM_connections()
	SaveFile.save(file)

func list_behaviors():
	for names in Behavior_names:
		BehaviorMenu.add_item(names)
		BehaviorList.add_item(names)

func load_behaviors_in(path : String) -> void:
	print(path)
	var Dir = Directory.new()
	if Dir.open(path) == OK:
		Dir.list_dir_begin()
		var file_name : String = Dir.get_next()
		print(file_name)
		while (file_name != ""):
			print(file_name)
			if not Dir.current_is_dir():
				print("found file: ", file_name)
				if file_name.ends_with(".jbt"):
					var BT = ConfigFile.new()
					BT.load(file_name)
					Behaviors.append(BT)
					Behavior_routes.append(Dir.get_current_dir()+"/"+file_name)
					Behavior_names.append(file_name.trim_suffix(".jbt"))
				else:
					print_debug("Found a file that is not a BT")
			elif file_name.is_valid_filename() and file_name != "." and file_name != "..":
				load_behaviors_in(file_name)
			file_name = Dir.get_next()
		Dir.list_dir_end()
	else: 
		print_debug("Error accessing ", path)

func save_SM_connections():
	var list = Graph.get_connection_list()
	for elements in list:
		var from : String = elements.get("from")
		var to : String = elements.get("to")
		if from.begins_with("@"):
			from = from.trim_prefix("@")
			from = from.replace("@", "_")
		if to.begins_with("@"):
			to = to.trim_prefix("@")
			to = to.replace("@", "_")
		elements["from"] = from
		elements["to"] = to
	SaveFile.set_value("config", "filtered_connections", list)

func _on_Behaviors_item_selected(index):
	current_idx = index

func _on_Add_pressed():
	Graph.add_state(BehaviorList.get_item_text(current_idx))


func _on_Save_pressed():
	$ViewMenuSplit/StatesGraphEdit/Save.popup_centered()

func _on_Open_pressed():
	pass # Replace with function body.


func _on_Save_file_selected(path):
	save_states(path)
	pass # Replace with function body.
