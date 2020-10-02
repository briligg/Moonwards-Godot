tool
extends VSplitContainer

var current_idx = 0
var Behaviors : Array = []
var Behavior_names : Array = []
var Behavior_routes : Array = []
var SaveFile : ConfigFile = ConfigFile.new()


onready var BehaviorList : ItemList = $ViewMenuSplit/Container/ScrollContainer/Behaviors
onready var BehaviorMenu : PopupMenu = $ViewMenuSplit/StatesGraphEdit/States
onready var Graph : GraphEdit = $ViewMenuSplit/StatesGraphEdit
onready var filepop : FileDialog = $ViewMenuSplit/StatesGraphEdit/Save
export(NodePath) var node_path = null
export(String, DIR) var BehaviorsPath = "res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/"

func _ready() -> void:
	var dir = Directory.new()
	dir.open(OS.get_user_data_dir())
	if not dir.dir_exists("behaviors"):
		dir.make_dir_recursive("behaviors")
	for element in Nodes.behavior_paths:
		load_behaviors_in(element)
	#Loads User Defined Behaviors
	list_behaviors()

func load_states():
	for key in SaveFile.get_section_keys("offsets"):
		Graph.add_state(key, -SaveFile.get_value("offsets", key))

func load_connections():
	for connection in SaveFile.get_value("config", "filtered_connections"):
		Graph.connect_node(
			connection.get("from"),
			connection.get("from_port"),
			connection.get("to"),
			connection.get("to_port")
		)

func load_variables():
	var node = get_node("ViewMenuSplit/Container/InspectorGadgetScrollContainer/InspectorGadget")
	for key in SaveFile.get_section_keys("variables"):
		var vars = SaveFile.get_value("variables", key)
		node.set_value_for_prop(key, vars)

func save_variables():
	var node = get_node(node_path)
	var Default = Node.new()
	var list = node.get_property_list()
	var list2 = Default.get_property_list()
	for variables in list.size():
		for variables2 in list2.size():
			if variables < list.size() and variables2 < list2.size():
				if list[variables].hash() == list2[variables2].hash():
					list.erase(list[variables])
	for element in list:
		if element.usage == 8199 and not element.name == "NPC_File": #Exported value
			SaveFile.set_value("variables", element.get("name"), node.get(element.get("name")))


func save_states(file : String):
	#First we save the routes to the nodes used in the machine
	if Graph.get_connection_list().size() == 0:
		print_debug("WARNING: Attempting to save a State Machine with no connections")
	var names : Array = Graph.get_unique_nodes()
	for _name in names:
		var idx : int = Behavior_names.find(_name)
		SaveFile.set_value("node_routes", _name, Behavior_routes[idx])
	save_SM_connections()
	save_variables()
	SaveFile.save(file)

func list_behaviors():
	BehaviorMenu.clear()
	BehaviorList.clear()
	for names in Behavior_names:
		BehaviorMenu.add_item(names)
		BehaviorList.add_item(names)

func load_behaviors_in(path : String) -> void:
	if path == "." or path == ".." or path == "":
		return
	var Dir = Directory.new()
	if Dir.open(path) == OK:
		Dir.list_dir_begin()
		var file_name : String = Dir.get_next()
		while (file_name != ""):
			if not Dir.current_is_dir():
				if file_name.ends_with(".jbt"):
					var BT = ConfigFile.new()
					BT.load(file_name)
					if Behavior_names.find(file_name.trim_suffix(".jbt"))==-1:
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
		var node_from : GraphNode = Graph.get_node(from)
		var to : String = elements.get("to")
		var node_to : GraphNode = Graph.get_node(to)
		if from.begins_with("@"):
			from = from.trim_prefix("@")
			from = from.replace("@", "_")
		if to.begins_with("@"):
			to = to.trim_prefix("@")
			to = to.replace("@", "_")
		elements["from"] = from
		elements["to"] = to
		SaveFile.set_value("offsets", from, node_from.offset)
		SaveFile.set_value("offsets", to, node_to.offset)
	SaveFile.set_value("config", "filtered_connections", list)

func _on_Behaviors_item_selected(index):
	current_idx = index

func _on_Add_pressed():
	Graph.add_state(BehaviorList.get_item_text(current_idx))

func _on_Save_pressed():
	filepop.set_save()
	filepop.popup_centered()

func _on_Open_pressed():
	filepop.set_open()
	filepop.popup_centered()

func _on_Save_file_selected(path):
	if filepop.mode == FileDialog.MODE_OPEN_FILE:
		Graph.clear_graph()
		yield(get_tree().create_timer(0.5), "timeout")
		SaveFile = ConfigFile.new()
		SaveFile.load(path)
		load_states()
		load_connections()
		load_variables()
	else:
		save_states(path)

func _on_Refresh_pressed():
	for element in Nodes.behavior_paths:
		load_behaviors_in(element)
	#Loads User Defined Behaviors
	list_behaviors()
