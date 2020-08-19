tool
extends GraphEdit

onready var popup = $PopupMenu
var m_position : Vector2 = Vector2.ZERO
func _on_GraphEdit_popup_request(position):
	popup.rect_position = position
	m_position = position
	popup.popup()

var ChoiceNode = load("res://addons/joyeux_dialog_system/src/components/ChoiceNode.tscn")


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
	node.offset = offset
	node.title = text
	node.set_slot(0, true, TYPE_BOOL, Color(1,1,1,1), true, TYPE_BOOL, Color(1,1,1,1))
	var popbutton = Button.new()
	popbutton.text = "Edit"
	popbutton.connect("pressed", text_popup, "popup_centered")
	node.add_child(popbutton)
	node.add_child(text_popup)
	add_child(node)


func _on_PopupMenu_id_pressed(id):
	match id:
		0:
			create_node("", "","",(scroll_offset + (m_position - rect_global_position))/zoom )
		2: 
			add_child(ChoiceNode.instance())
		3: 
			var child = ChoiceNode.instance()
			child.interface_type = child.TEXT_INPUT
			add_child(child)
