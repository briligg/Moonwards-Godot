tool
extends Node
const TYPE_ANY = 28
onready var Definitions
var Colors = [
	Color(0,0,0,0),
	Color("#c96ef0"),
	Color("#42f5ce"),
	Color("#45c4ff"),
	Color("#ffbe45"),
	Color(0.2,0.4,0.4,1),
	Color(0.4,0.4,0.4,1),
	Color("#00ff44"),
	Color(0.6,0.4,0.4,1),
	Color(0.6,0.6,0.4,1),
	Color(0.6,0.6,0.6,1),
	Color(0.6,0.6,0.8,1),
	Color(0.6,0.8,0.8,1),
	Color(0.8,0.8,0.8,1),
	Color(1,0.8,0.8,1),
	Color(1,1,0.8,1),
	Color(1,1,1,1),
	Color("#f50076"),
	Color("#ff1717"),
	Color("#ffff21"),
	Color(0.1,0.6,0.1, 1),
	Color(0.6, 0.2, 0.7, 1),
	Color(0.9,0.1,0.9,1),
	Color(0.2,0,0.2,1),
	Color("#00ef44"),
	Color(0.5, 0, 0.5),
	Color(0.2, 1, 0.1),
	Color(1,0.5,0.2,1),
	Color("#ffffff")
	]
var Graphs : Dictionary = {
	"actions" : {
		#here you could add manually made nodes
	},

	"stimulus" : {
	#
	},

	"inhibitors" : {
		#"Decision" : preload("res://Nodes/Inhibitors/Decision.tscn")
		#this is an example for pre defined nodes, that do not follow the definitions file
	},
	"misc" : {

	}
}

var custom_types : Dictionary = {}
var user_override : String = "" 
var proj_override : String = "" 
var behavior_paths : Array = [
	"res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/",
	OS.get_user_data_dir()+"/behaviors"
]

func override_default(which : int, dir : String):
	match which:
		0:
			proj_override = dir
		1:
			user_override = dir
		_:
			if behavior_paths.size() < which and which  >= 0:
				behavior_paths[which] = dir

func load_custom_paths():
	var Conf = ConfigFile.new()
	var err = Conf.load("res://addons/joyeux_npc_editor/Config/paths.cfg")
	if err != OK:
		return
	
	if Conf.has_section_key("overrides", "0"):
		behavior_paths[0] = Conf.get_value("overrides", "0")
	if Conf.has_section_key("overrides", "1"):
		behavior_paths[1] = Conf.get_value("overrides", "1")
	
	for key in Conf.get_section_keys("behaviors"):
		if not behavior_paths.has(Conf.get_value("behaviors", key)):
			behavior_paths.append(Conf.get_value("behaviors", key))

func save_custom_paths():
	var Conf = ConfigFile.new()
	if behavior_paths.size() < 2:
		return
	for idx in range(0, behavior_paths.size()):
		Conf.set_value("behaviors", str(idx), behavior_paths[idx])
	if user_override != "":
		Conf.set_value("overrides", str(0), user_override)
	if proj_override != "":
		Conf.set_value("overrides", str(1), proj_override)
	Conf.save("res://addons/joyeux_npc_editor/Config/paths.cfg")


func _is_format_correct() -> bool:
	if Definitions.get("_functions") == null or Definitions.get("_stimulus") == null:
		return false
	else:
		return true

func _are_valid_identifiers(strings : Array)->bool:
	for string in strings:
		if not string.is_valid_identifier():
			return false
	return true


func _get_port_name(data : Dictionary, port : int, input : bool = true) -> String:
	var ports : Array = []
	if input:
		ports = data.get("_input_ports")
	else:
		ports = data.get("_output_ports")
	if port < ports.size():
		return ports[port].get("_label_title")
	else:
		return ""

func _get_port_type(data : Dictionary, port : int, input : bool = true):
	var ports : Array = []
	if input:
		ports = data.get("_input_ports")
	else:
		ports = data.get("_output_ports")
	if port < ports.size():
		return _get_type(ports[port].get("_type"))
	else:
		return TYPE_NIL

func _get_type(type) -> int:
	if type is int:
		return type # The type is already a number we don't have to do anything
	elif type is String: #Type is custom, we have to find it
		var custom : bool = custom_types.has(type.trim_prefix("CLASS_"))
		if custom == false:
			return TYPE_NIL #If not defined we return NIL
		else:
			return 28+Definitions.get(type).idx #28 is the Any type, this one is locked out.
	return TYPE_NIL

func _load_signals() -> void:
	var signal_list : Dictionary = Definitions.get("_stimulus")
	var signal_names : Array = signal_list.keys()
	for signals in signal_names:
		var data : Dictionary = signal_list.get(signals)
		var current_node : GraphNode = GraphNode.new()
		current_node.title = signals
		current_node.add_child(DoubleLabel.new("", data.get("_output_name")))
		current_node.set_slot(0,false,TYPE_NIL,0, true,
			_get_type(data.get("_output_type")),  #the type may be a string, so we need to parse it
			self.Color(data.get("_output_type"))) #Special case, color parses strings
		Graphs.stimulus[signals]=current_node


func _load_functions() -> void:
	var functions : Dictionary = Definitions.get("_functions")
	var function_names = functions.keys()
	if not _are_valid_identifiers(function_names):
		Log.warning(self,"_load_functions", "A function name is not correct, please verify your definitions.")
		return
	for function in function_names:
		var data : Dictionary = functions.get(function)
		var current_node : GraphNode = BehaviorNode.new()
		current_node.title = function
		for ports in max(data.get("_input_ports").size(),data.get("_output_ports").size()):
			current_node.set_slot(
				ports,
				_get_port_type(data, ports, true),
				_get_port_type(data, ports, true),
				self.Color(_get_port_type(data, ports, true)),
				_get_port_type(data, ports, false),
				_get_port_type(data, ports, false),
				self.Color(_get_port_type(data, ports, false)))
			current_node.add_child(DoubleLabel.new(
				_get_port_name(data, ports, true),
				_get_port_name(data, ports, false)
			))
			#At this point we have created the node, let's store it
		match data.get("_category"):
			"inhibitors":
				Graphs.inhibitors[function]=current_node
			"actions":
				Graphs.actions[function]=current_node
			"misc":
				Graphs.misc[function]=current_node


func _load_definitions() -> void:
	var idx : int = 0
	if not _is_format_correct():
		return
	var all_properties = Definitions.get_property_list()
	var Classes : Array = []
	for properties in all_properties:
		if properties.get("name").begins_with("CLASS_"):
			Classes.append(properties.get("name"))
	#At this point all_properties has been filtered
	for Class in Classes:
		idx = idx + 1
		Definitions.get(Class)["idx"] = idx
		Colors.append(Definitions.get(Class)["_color"])
		custom_types[Class.trim_prefix("CLASS_")] = Definitions.get(Class).get("_variables")

func _color_from_class(id : String) -> Color:
	var Class = Definitions.get(id)
	var color : Color = Color(0)
	if Class != null:
		color = Class.get("_color")
	return color

func filter_node_name(unfiltered : String) -> String:
	for i in range(0,9):
		unfiltered = unfiltered.replace(str(i),"")
	unfiltered = unfiltered.replace("@","")
	unfiltered = unfiltered.replace(":", "")
	unfiltered = unfiltered.replace("/", "")
	unfiltered = unfiltered.replace("-", "")
	unfiltered = unfiltered.replace("+", "")
	unfiltered = unfiltered.replace(".", "")
	return unfiltered

func Color(id) -> Color:
	if id is int:
		if id <= Colors.size():
			return Colors[id] #If the color is from a default type, looks for it
	elif id is String:
		#If the color is from a custom class, loads it from the Definitions.
		return _color_from_class(id)
	return Color(0)

func initiate() -> void:
	Definitions =  NpcDefinitions.new()
	load_custom_paths()
	_load_definitions()
	_load_functions()
	_load_signals()

#	load_user_defined_nodes()
"""
func load_user_defined_nodes() -> void:
	var Dir = Directory.new()
	var CustomNodes : Array = []
	if  not Dir.dir_exists("user://CustomNodes/"):
		Dir.make_dir("user://CustomNodes/")
	Dir.open("user://CustomNodes/")
	Dir.list_dir_begin(true, true)
	var file = Dir.get_next()
	while (file!=""):
		CustomNodes.append(file)
		file = Dir.get_next()
	for N in CustomNodes:
		if N.matchn("*.tscn"):
			N = N.replace(".tscn","")
			Graphs.custom[N]=load(str("user://CustomNodes/",N,".tscn"))
"""
