extends VSplitContainer

var current_idx = 0
var Behaviors : Array = []
var Behavior_names : Array = []

onready var BehaviorList : ItemList = $ViewMenuSplit/Container/ScrollContainer/Behaviors

func _ready() -> void:
	var dir = Directory.new()
	dir.open(OS.get_user_data_dir())
	dir.make_dir_recursive("behaviors")
	load_behaviors_in(OS.get_user_data_dir()+"/behaviors")
	#Loads User Defined Behaviors
	load_behaviors_in("res://SceneComponent/Actor/Humanoid/NPCs/DefaultBehaviors")
	#Loads Default behaviors
	list_behaviors()

func list_behaviors():
	for names in Behavior_names:
		print(names)
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
					Behavior_names.append(file_name.trim_suffix(".jbt"))
				else:
					print_debug("Found a file that is not a BT")
			elif file_name.is_valid_filename() and file_name != "." and file_name != "..":
				load_behaviors_in(file_name)
			file_name = Dir.get_next()
		Dir.list_dir_end()
	else: 
		print_debug("Error accessing ", path)
		
func add_state(text):
	var node : GraphNode = GraphNode.new()
	node.title = text
	node.add_child(Label.new())
	node.set_slot(0, true, 1, Color(1,1,1,1), true, 1, Color(1,1,1,1))
	$ViewMenuSplit/StatesGraphEdit.add_child(node)
func _on_Behaviors_item_selected(index):
	current_idx = index

func _on_Add_pressed():
	add_state(BehaviorList.get_item_text(current_idx))
