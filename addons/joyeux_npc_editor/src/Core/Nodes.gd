tool
extends Node
const TYPE_ANY = 28
onready var Definitions
const Colors = [
	Color(0,0,0,0),
	Color(0.2,0,0,1),
	Color(0.2,0.8,0.4,1),
	Color(0.2,1.2,1.2,1),
	Color(0.2,0.2,0.4,1),
	Color(0.2,0.4,0.4,1),
	Color(0.4,0.4,0.4,1),
	Color(0.4,0,0),
	Color(0.6,0.4,0.4,1),
	Color(0.6,0.6,0.4,1),
	Color(0.6,0.6,0.6,1),
	Color(0.6,0.6,0.8,1),
	Color(0.6,0.8,0.8,1),
	Color(0.8,0.8,0.8,1),
	Color(1,0.8,0.8,1),
	Color(1,1,0.8,1),
	Color(1,1,1,1),
	Color(1,0,1,1),
	Color(1,1,0,1),
	Color(0.5, 0.2, 0.2, 1),
	Color(0.1,0.6,0.1, 1),
	Color(0.6, 0.2, 0.7, 1),
	Color(0.9,0.1,0.9,1),
	Color(0.2,0,0.2,1),
	Color(0.7, 0, 0.5),
	Color(0.5, 0, 0.5),
	Color(0.2, 1, 0.1),
	Color(1,0.5,0.2,1),
	Color(0.1,0.2,0.3,1)
	]
var custom_types : Dictionary = {}

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

func _get_port_type(data : Dictionary, port : int, input : bool = true) -> int:
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
		var custom : bool = custom_types.has(type)
		if custom == false:
			return TYPE_NIL #If not defined we return NIL
		else:
			return 28+custom_types.get(type.trim_prefix("CLASS_")).idx #28 is the Any type, this one is locked out.
	return TYPE_NIL

func _load_signals():
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


func _load_functions():
	var functions : Dictionary = Definitions.get("_functions")
	var function_names = functions.keys()
	if not _are_valid_identifiers(function_names):
		print_debug("A function name is not correct, please verify your definitions.")
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
		custom_types[Class.trim_prefix("CLASS_")] = Definitions.get(Class).get("_variables")



func Color(id) -> Color:
	if id is int:
		if id <= Colors.size():
			return Colors[id] #If the color is from a default type, looks for it
	elif id is String:
		#If the color is from a custom class, loads it from the Definitions.
		return _color_from_class(id)
	return Color(0)

func _color_from_class(id : String) -> Color:
	var Class = Definitions.get(id)
	var color : Color = Color(0)
	if Class != null:
		color = Class.get("_color")
	return color


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



func _enter_tree() -> void:
	Definitions =  NpcDefinitions.new()
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
