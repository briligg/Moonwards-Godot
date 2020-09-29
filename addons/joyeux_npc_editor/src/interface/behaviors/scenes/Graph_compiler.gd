tool
extends GraphEdit

var idx : int = 0
var last_mouse_pos : Vector2 = Vector2.ZERO

var SceneNodes : Dictionary
var Currently_selected : Node = null
var OutputFile : ConfigFile = ConfigFile.new()

onready var save = $Save
func _ready() -> void:
	connect("node_selected", self, "_on_node_selected")
	for type in range (0,27):
		add_valid_connection_type(28,type)
#		add_valid_connection_type(type, 28)

func clear_graph() -> void:
	for child in get_children():
		if child is GraphNode:
			child.queue_free()
	emit_signal("nodes_deleted")

func load_nodes() -> void:
	var connections = OutputFile.get_value("ai_config", "connections")
	for name in ["from", "to"]:
		
		for connection in connections:
			#First load and create the nodes
			var filtered = Nodes.filter_node_name(connection.get(name))
			var unfiltered = connection.get(name)
			var type 
			for cat in Nodes.Graphs:
				if Nodes.Graphs.get(cat).has(filtered):
					type = cat
#					print(cat)
			var offset = OutputFile.get_value("node_offsets", unfiltered)
			if not has_node(connection.get(name)):
				add_node(type, unfiltered, offset)
				print("Node added: ", unfiltered)
			for child in get_node(unfiltered).get_child_count():
				var variables = OutputFile.get_value("variables", unfiltered)
				if child < variables.size():
					recursive_set_variable(
						get_node(unfiltered).get_child(child),
						variables[child])
	for connection in connections:
		#Next, connect the nodes as they were saved
		_on_GraphEdit_connection_request(
			connection.get("from"),
			connection.get("from_port"),
			connection.get("to"),
			connection.get("to_port")) 


func add_node_offset(type : String, node_name : String):
	var node_start_pos = (scroll_offset + (last_mouse_pos - rect_global_position))/zoom 
	add_node(type, node_name, node_start_pos)

func add_node(type : String, node_name : String, offset : Vector2 = Vector2.ZERO) -> void:
	if (type == "" or node_name == ""):
		return
	var filtered = Nodes.filter_node_name(node_name)
	var instanced = Nodes.Graphs.get(type).get(filtered)
	if instanced is Node:
		instanced = instanced.duplicate()
	else:
		instanced = instanced.instance()
	instanced.offset = offset
	instanced.name = node_name 
	add_child(instanced)
	idx += 1
	
func _input(event):
	if event is InputEventKey:
		if Input.is_action_pressed("Shift") and Input.is_key_pressed(KEY_A):
			popup_add_menu()
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
	elif node is EnumDropDown:
		print("It's enum, idx is ", node.index)
		return node.index
	elif node is DropDown:
		return node.text
	else:
		for child in node.get_children():
			var found = recursive_get_variable(child)
			if found != null:
				return found
	return null

func recursive_set_variable(node : Node, variable):
	if node is Label:
		return OK
	elif node is LineEdit:
		node.text = variable
		return 
	elif node is SpinBox:
		node.value = variable
		return 
	elif node is EnumDropDown:
		node.set_index(variable)
	elif node is DropDown:
		node.get_popup().text = variable
		return 
	else:
		for child in node.get_children():
			var found = recursive_set_variable(child, variable)
			if found == OK:
				return 
	return 
	

func compile(connections):
	for section in OutputFile.get_sections():
		OutputFile.erase_section(section)
	var node : Control
	for child in get_child_count():
		var node_info : Array = []
		node = get_child(child) #These are most of the time GraphNodes
		
		var nodevars : Array = [] # Here the variables will be stored
		for child2 in node.get_children(): #For each children in the GraphNode
			if node is GraphNode: #Checks if it's actuallly a GraphNode
				var found = recursive_get_variable(child2)
				nodevars.append(found)
		OutputFile.set_value("variables", node.name, nodevars)
		if node is GraphNode:
			for inputs in max(
					node.get_connection_output_count(),
					node.get_connection_input_count()):
				
				if node.is_slot_enabled_right(inputs):
					if Nodes.Graphs.stimulus.has(Nodes.filter_node_name(node.name)):
						node_info.append(Nodes.filter_node_name(node.name))
					else:
						node_info.append(str(node.name,"_output_",inputs))
			OutputFile.set_value("node_signals", node.name, node_info)
			OutputFile.set_value("node_offsets", node.name, node.offset)
	OutputFile.set_value("ai_config", "connections", connections)

func popup_add_menu():
	$Behaviors.rect_position = last_mouse_pos
	$Behaviors.popup()

func _on_node_selected(node):
	Currently_selected = node
	
func _on_Button3_pressed():
	pass

func is_slot_occupied(to, to_port):
	for connection in get_connection_list():
		var from_port = connection.get("from_port")
		var from = connection.get("from")
		if is_node_connected(from, from_port, to, to_port ):
			return true

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot) -> void:
	if from != to and not is_slot_occupied(to, to_slot):
		connect_node(from, from_slot, to, to_slot)
		if get_node(to).has_signal("connected_to"):
			get_node(to).emit_signal("connected_to", to_slot, 
				get_node(from).get_slot_type_right(from_slot))

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot) -> void:
	disconnect_node(from, from_slot, to, to_slot )
	get_node(to).emit_signal("disconnected_from", to_slot)

func _on_save_file_selected(path):
	if save.mode == FileDialog.MODE_SAVE_FILE:
		OutputFile.save(path)
	else:
		OutputFile = ConfigFile.new()
		OutputFile.load(path)
		clear_graph()
		yield(get_tree().create_timer(0.5), "timeout")
		load_nodes()

func _on_save_pressed():
	compile(get_connection_list())
	save.set_save()
	save.popup_centered()

func _on_GraphEdit_popup_request(position):
	last_mouse_pos = position
	popup_add_menu()
