extends GraphEdit

var SceneNodes : Dictionary
var Currently_selected : Node = null
var OutputFile : ConfigFile = ConfigFile.new()

func _ready():
	connect("node_selected", self, "_on_node_selected")
	for type in range (0,27):
		add_valid_connection_type(28,type)
#		add_valid_connection_type(type, 28)

func add_node(name : String):
	var REGEX : RegEx = RegEx.new()
	REGEX.compile(".[A-Za-z]*[\\s*[A-Za-z]*]*[^0-9]")
	var Result : Array = REGEX.search_all(name)
	if Result == null:
		print("No matches, names don't match the RegEx")
		return
	if Result.size() > 0:
		print("Theres a result")
		if Nodes.Graphs.inhibitors.has(Result[0].get_string()):
			SceneNodes[name]=Nodes.Graphs.inhibitors.get(Result[0].get_string()).instance()
			return
		if Nodes.Graphs.custom.has(Result[0].get_string()):
			SceneNodes[name]=Nodes.Graphs.custom.get(Result[0].get_string()).instance()
			return
		if Nodes.Graphs.stimulus.has(Result[0].get_string()):
			SceneNodes[name]=Nodes.Graphs.stimulus.get(Result[0].get_string()).instance()
			return
		if Nodes.Graphs.misc.has(Result[0].get_string()):
			SceneNodes[name]=Nodes.Graphs.misc.get(Result[0].get_string()).instance()
			return
		if Nodes.Graphs.actions.has(Result[0].get_string()):
			SceneNodes[name]=Nodes.Graphs.actions.get(Result[0].get_string()).instance()
			return
		else:
			print("Non-existant node ",Result[0].get_string() ,", check your Character Studio version, if this is a custom node, please use only letters and spaces for the title")
	
func _input(event):
	if event is InputEventKey:
		if Input.is_action_pressed("Shift") and Input.is_key_pressed(KEY_A):
			$Behaviors.rect_position = get_tree().get_root().get_mouse_position()
			$Behaviors.popup()
		if Input.is_key_pressed(KEY_DELETE) and Currently_selected != null:
			var all_connections : Array = get_connection_list()
			for connection in all_connections:
				var from_port = connection.get("from_port")
				var from = connection.get("from")
				var to_port = connection.get("to_port")
				var to = connection.get("to")
				if (Currently_selected.name == from or Currently_selected.name == to):
					disconnect_node(from,from_port,to,to_port)
			if is_instance_valid(Currently_selected):
				Currently_selected.clear_all_slots()
				Currently_selected.queue_free()
				update()
			
func recursive_get_variable(node : Node):
	if node is Label:
		return null
	elif node is LineEdit:
		return node.text
	elif node is SpinBox:
		return node.value
	elif node is MenuButton:
		return node.get_popup().text
	else:
		for child in node.get_children():
			var found = recursive_get_variable(child)
			if found != null:
				return found
	return null

func compile(connections):
	var node : Control
	for child in get_child_count():
		var node_info : Array = []
		node = get_child(child)
		
		var nodevars : Array = []
		for child2 in node.get_children():
			if not child2 is GraphNode:
				continue
			nodevars.append(recursive_get_variable(child))
		OutputFile.set_value("variables", node.name, nodevars)
		if node is GraphNode:
			for inputs in max(
					node.get_connection_output_count(),
					node.get_connection_input_count()):
				
				if node.is_slot_enabled_right(inputs):
					node_info.append(str(node.name,"_output_",inputs))
			OutputFile.set_value("node_signals", node.name, node_info)
	OutputFile.set_value("ai_config", "connections", connections)




func open(SaveArray : Array):
	for connection in SaveArray:
		if not SceneNodes.has(connection.from):
			add_node(connection.from)
		if not SceneNodes.has(connection.to):
			add_node(connection.to)

func _on_node_selected(node):
	Currently_selected = node
	
func _on_Button3_pressed():
	pass

func is_slot_occupied(to_port, to):
	for connection in get_connection_list():
		var from_port = connection.get("from_port")
		var from = connection.get("from")
		if is_node_connected(from, from_port, to, to_port ):
			return true

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot) -> void:
	print("Requesting conection from node: ", from, " port: ", from_slot, " to node: ", to, " port: ", to_slot)
	if from != to:
		connect_node(from, from_slot, to, to_slot)
		if get_node(to).has_signal("connected_to"):
			get_node(to).emit_signal("connected_to", to_slot, 
				get_node(from).get_slot_type_right(from_slot))


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot) -> void:
	disconnect_node(from, from_slot, to, to_slot )
	get_node(to).emit_signal("disconnected_from", to_slot)



func _on_GraphEdit_node_selected(node : GraphNode):
	print(node.get_slot_type_right(0), ", ",  node.get_slot_type_left(0))
	pass # Replace with function body.


func _on_save_file_selected(path):
	OutputFile.save(path)


func _on_save_pressed():
	compile(get_connection_list())
	$Save.popup_centered()
