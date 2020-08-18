tool
extends GraphEdit


func _on_GraphEdit_popup_request(position):
	create_node("", "","",(scroll_offset + (position - rect_global_position))/zoom )


func _on_GraphEdit_delete_nodes_request():
	for child in get_children():
		if child is GraphNode:
			if child.selected:
				for connections in get_connection_list():
					if connections.get("from") == child.name or	connections.get("to") == child.name:
						disconnect_node(
							connections.get("from"), 
							connections.get("from_port"), 
							connections.get("to"), 
							connections.get("to_port"))
				child.queue_free()
func is_slot_occupied(to, to_port):
	for connection in get_connection_list():
		var from_port = connection.get("from_port")
		var from = connection.get("from")
		if is_node_connected(from, from_port, to, to_port ):
			return true

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
		if from != to and not is_slot_occupied(to, to_slot):
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
