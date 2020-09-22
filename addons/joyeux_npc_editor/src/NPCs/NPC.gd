class_name NPCBase

signal next_state(force)

var destination : Vector3 = Vector3.ZERO
var has_destination : bool = false
var is_occpuied : bool = false

var ai_script : ConfigFile = ConfigFile.new()
var current_state : String 
var states : Dictionary = {} #Stores the states and their next states
var behaviors : Dictionary = {} #Stores the loaded behaviors

export(String, FILE, "*.jsm") var NPC_File : String = "" #This works just fine! :D
export(String) var initial_state : String = ""



func _ready():
	randomize()
	_load_states(NPC_File)
	

func _create_signal(signal_name : String):
	if not has_signal(signal_name):
		add_user_signal(signal_name)

func _load_states(state_file : String):
	if state_file != "":
		ai_script.load(state_file) 
		_load_connection_dict(ai_script.get_value("config", "filtered_connections", []))
		_load_behaviors_in_machine()
		_load_variables()
		_start_machine()
	else:
		print_debug("Error: No State Machine File selected")

func _load_variables():
	for key in ai_script.get_section_keys("variables"):
		var vars = ai_script.get_value("variables", key)
		set(key, vars)

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

func _load_behaviors_in_machine():
	var keys = ai_script.get_section_keys("node_routes")
	for key in keys:
		_load_behavior_script(ai_script.get_value("node_routes", key), key)

func _load_behavior_script(AI_file : String, behavior_name : String = ""):
	#Loads and stores all behavior files included in the state machine
	var bt_file = ConfigFile.new()
	bt_file.load(AI_file)
	behaviors[behavior_name] = bt_file
	
func _start_machine():
	for state in states.keys():
		if state.begins_with("_start") or state == initial_state:
			current_state = state 
			_change_behavior(behaviors.get(current_state))
			return
	print_debug("Error: This states file has no start state defined")

func _next_state(force : bool = false, condition = null):
	#Sets the next state in the machine
	var next_states = states.get(current_state)
	#Disconnects the current behavior
	_undefine_connection(behaviors.get(current_state))
	if not next_states.size() >= 1:
		_start_machine()
	else:
		current_state = next_states[int(rand_range(0, next_states.size()))]
		#Connects the new behavior
		_change_behavior(behaviors.get(current_state))


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


		
func _change_behavior(behavior : ConfigFile):
	#loads the behavior provided
	for signals in behavior.get_section_keys("node_signals"):
		_create_signal(signals)
	for connection in behavior.get_value("ai_config", "connections", []):
		_define_connection(behavior, 
			connection.get("from"),
			connection.get("from_port"),
			connection.get("to"), 
			connection.get("to_port"))
		
func _clean_function_name(f_name)->String:
	#This section ahead cleans up the node name to get the function name instead
	f_name = f_name.replace("@", "")
	for number in range (0, 9):
		f_name = f_name.replace(str(number), "")
	return f_name

func _define_connection(behavior : ConfigFile, from : String, from_port : String , to: String, to_port : String):
	#The only information passed from signal to
	var signal_name = from+"_output_"+from_port
	var connection_bindings : Array = []
	#add the signals related to this node to the bindings
	connection_bindings.append(behavior.get_value("node_signals", to, []))
	connection_bindings.append(behavior.get_value("variables", to, []))
	var function =_clean_function_name(to) 
	#name cleaned up
	if has_signal(signal_name) and has_method(function):
			connect(signal_name, self, function, connection_bindings) 
	else:
		print_debug("Warning: Either a signal or a method is missing from the NPC")
		
func _undefine_connection(behavior : ConfigFile):
	for connection in behavior.get_value("ai_config", "connections", []):
		var function = _clean_function_name(connection.get("to"))
		for signals in behavior.get_section_keys("node_signals"):
			if is_connected(signals, self, function):
				disconnect(signals, self, function)
