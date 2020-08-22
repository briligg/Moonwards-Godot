tool
extends GraphEdit

var m_position : Vector2 = Vector2.ZERO
var ChoiceNode = load("res://addons/joyeux_dialog_system/src/components/ChoiceNode.tscn")

onready var popup = $PopupMenu

func clear_graph():
	clear_connections()
	for child in get_children():
		if child is GraphNode and child.name != "Start":
			child.queue_free()
	yield(get_tree().create_timer(0.5), "timeout")

func save_dialogs(path : String, character_name : String) -> void:
	var file = ConfigFile.new()
	var connections = get_connection_list()
	for child in get_children():
		if child is GraphNode:
			
			var next = []
			for connection in connections:
					if connection.get("from") == child.name:
						next.append(connection.get("to"))
			
			file.set_value("offsets", child.name, child.offset)
			
			if child.title == "Choice" or child.title == "Text input match":
				if child.title == "Choice":
					file.set_value("choices", child.name, child.get_options())
				else:
					file.set_value("matches", child.name, child.get_options())
				next.clear()
				for connection in connections:
					if connection.get("from") == child.name:
						var option = {
							"name" : child.get_option(connection.get("from_port")),
							"triggers" : connection.get("to")
						}
						next.append(option)
				file.set_value("choices_triggers", child.name, next)
				
			if child.has_node("content"):
				if next.size() == 0:
					next = ""
				else:
					next = next[0]
				var dialog = {
					"title" : child.get_node("content").title,
					"content" : child.get_node("content").content,
					"name_override" : child.get_node("content").override,
					"next" : next
				}
				file.set_value("dialogs", child.name, dialog)
	file.set_value("config", "connections", connections)
	file.set_value("config", "character_name", character_name)
	file.save(path)
	pass

func load_dialogs(path : String) -> void:
	clear_graph()
	yield(get_tree().create_timer(1),"timeout")
	var fload : ConfigFile = ConfigFile.new()
	fload.load(path)
	var offsets : Dictionary = {}
	#Obtain all node offsets and store them for later
	for key in fload.get_section_keys("offsets"):
		offsets[key] = fload.get_value("offsets", key)
		
	if fload.has_section("dialogs"):
		for key in fload.get_section_keys("dialogs"):
			var dialog = fload.get_value("dialogs", key)
			create_node(dialog.get("title"), dialog.get("content"), dialog.get("name_override"), offsets.get(key))
			
	if fload.has_section("choices"):
		for key in fload.get_section_keys("choices"):
			create_option(false, offsets.get(key), fload.get_value("choices", key))
	if fload.has_section("matches"):
		for key in fload.get_section_keys("matches"):
			create_option(true, offsets.get(key), fload.get_value("matches", key))
	get_node("Start").offset = offsets.get("Start")
	for connection in fload.get_value("config", "connections"):
#		var node : GraphNode = get_node(connection.get("from"))
#		if node.is_slot_enabled_right(connection.get("from_port")) and not node.is_slot_enabled_left(connection.get("from_port")):
			connect_node(connection.get("from"),
				connection.get("from_port"),
				connection.get("to"), 
				connection.get("to_port"))
	get_parent().get_parent().CharNameEdit.text = fload.get_value("config", "character_name")


func is_slot_occupied(from, from_port) -> bool:
	for connection in get_connection_list():
		var to_port = connection.get("to_port")
		var to = connection.get("to")
		if is_node_connected(from, from_port, to, to_port ):
			return true
	return false


func create_option(text : bool = false, offset : Vector2 = Vector2.ZERO, options : Array  = []):
	var child = ChoiceNode.instance()
	if text:
		child.interface_type = child.TEXT_INPUT
	child.offset = offset
	child.set_options(options)
	add_child(child)

func create_node(text: String = "", input : String = "", override : String = "", offset : Vector2 = Vector2.ZERO):
	var node = GraphNode.new()
	var text_popup = TextPopup.new(text, input, override)
	text_popup.name = "content"
	node.offset = offset
	node.title = text
	node.set_slot(0, true, TYPE_BOOL, Color(1,1,1,1), true, TYPE_BOOL, Color(1,1,1,1))
	var popbutton = Button.new()
	popbutton.text = "Edit"
	popbutton.connect("pressed", text_popup, "popup_centered")
	node.add_child(popbutton)
	node.add_child(text_popup)
	add_child(node)

func _on_GraphEdit_delete_nodes_request():
	for child in get_children():
		if child is GraphNode:
			if child.selected and not child.name == "Start":
				for connections in get_connection_list():
					if connections.get("from") == child.name or	connections.get("to") == child.name:
						disconnect_node(
							connections.get("from"), 
							connections.get("from_port"), 
							connections.get("to"), 
							connections.get("to_port"))
				child.queue_free()
				
func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
		if from != to and not is_slot_occupied(from, from_slot):
			connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_popup_request(position):
	popup.rect_position = position
	m_position = position
	popup.popup()
	
func _on_PopupMenu_id_pressed(id):
	match id:
		0:
			create_node("", "","",(scroll_offset + (m_position - rect_global_position))/zoom )
		2: 
			create_option(false, (scroll_offset + (m_position - rect_global_position))/zoom)
		3: 
			create_option(true, (scroll_offset + (m_position - rect_global_position))/zoom)
