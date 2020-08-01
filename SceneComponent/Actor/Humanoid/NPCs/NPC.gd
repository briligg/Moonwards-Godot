extends Spatial

class_name NPCBase

signal next_state(force)
onready var actor = get_parent()

var destination : Vector3 = Vector3.ZERO
var has_destination : bool = false
var is_occpuied : bool = false
var states : Dictionary = {}
var ai_script : ConfigFile = ConfigFile.new()

export(String) var initial_state : String = ""

export(String, FILE, "*.jsm") var NPC_File : String = "" #This works just fine! :D

var current_state : String

func _ready():
	randomize()
	
func _load_connection_dict(connections):
	for elements in connections:
		var current_node : String = ""
		#checks connection dictionaries in the array
		if elements.has("from"):
			if states.has(elements.get("from")):
				#If the from node has already been registered
				states.get(elements.get("from")).append(elements.get("to"))
			else:
				#Register the node in case it hasn't been done yet
				states[elements.get("from")] = [elements.get("to")]

func _start_machine():
	for state in states.keys():
		if state.begins_with("_start"):
			current_state = state 
			return
	print_debug("This states file has no start state defined")

func _next_state(force : bool = false, condition = null):
	var next_states = states.get(current_state)
	if not next_states.size() >= 1:
		_start_machine()
	else:
		current_state = next_states[int(rand_range(0, next_states.size()))]

func _load_states(state_file):
	ai_script.load(state_file) 
	_load_connection_dict(ai_script.get_value("config", "filtered_connections", []))
	pass


func _emit_signal_from_port(what, signals : Array, port : int) -> void:
	if not signals.size() >= port:
		return
	if signals[port]!=null:
		emit_signal(signals[port], what)

func _node_set_meta(meta, signals, variables):
	set_meta(_get_variable_from_port(variables, 1), meta)

func _get_var_or_meta(string):
	if has_meta(string):
		return get_meta(string)
	return get(string)

func _get_variable_from_port(variables : Array, port : int):
	if not port >= variables.size():
		return
	return variables[port]

func _load_script(AI_file : String): #Path to a BT
	ai_script.load(AI_file)
	for signals in ai_script.get_section_keys("node_signals"):
		add_user_signal(signals)
	for connection in ai_script.get_value("ai_config", "connections", []):
		_define_connection(connection.get("from"),
			connection.get("from_port"),
			connection.get("to"), 
			connection.get("to_port"))
		
func _define_connection(from : String, from_port : String , to: String, to_port : String):
	#The only information passed from signal to
	var signal_name = from+"_output_"+from_port
	var connection_bindings : Array = []
	#add the signals related to this node to the bindings
	connection_bindings.append(ai_script.get_value("node_signals", to, []))
	connection_bindings.append(ai_script.get_value("variables", to, []))
	var function = to 
	#This section ahead cleans up the node name to get the function name instead
	function = function.replace("@", "")
	for number in range (0, 9):
		function = function.replace(str(number), "")
	#name cleaned up
	connect(signal_name, self, function, connection_bindings) 

