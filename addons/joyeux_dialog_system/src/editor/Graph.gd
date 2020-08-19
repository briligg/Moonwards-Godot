tool
extends GraphEdit

var m_position : Vector2 = Vector2.ZERO
var ChoiceNode = load("res://addons/joyeux_dialog_system/src/components/ChoiceNode.tscn")

onready var popup = $PopupMenu

func _on_GraphEdit_popup_request(position):
	popup.rect_position = position
	m_position = position
	popup.popup()

func save_dialogs(path : String, character_name : String) -> void:
	var file = ConfigFile.new()
	var connections = get_connection_list()
	for child in get_children():
		if child is GraphNode:
			
			var next : Array = []
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
	pass

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
				
func is_slot_occupied(from, from_port) -> bool:
	for connection in get_connection_list():
		var to_port = connection.get("to_port")
		var to = connection.get("to")
		if is_node_connected(from, from_port, to, to_port ):
			return true
	return false

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
		if from != to and not is_slot_occupied(from, from_slot):
			connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)

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

func create_option(text : bool = false, offset : Vector2 = Vector2.ZERO, options : Array  = []):
	var child = ChoiceNode.instance()
	if text:
		child.interface_type = child.TEXT_INPUT
	child.offset = (scroll_offset + (m_position - rect_global_position))/zoom
	add_child(child)

func _on_PopupMenu_id_pressed(id):
	match id:
		0:
			create_node("", "","",(scroll_offset + (m_position - rect_global_position))/zoom )
		2: 
			create_option(false, (scroll_offset + (m_position - rect_global_position))/zoom)
		3: 
			create_option(true, (scroll_offset + (m_position - rect_global_position))/zoom)
