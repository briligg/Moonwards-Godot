tool
extends GraphEdit

var last_mouse_pos : Vector2 = Vector2.ZERO

			
func clear_graph():
	for nodes in get_children():
		if nodes is GraphNode:
			nodes.queue_free()
	
func add_state(text : String, position : Vector2 = Vector2.ZERO):
	var node : GraphNode = GraphNode.new()
	node.title = Nodes.filter_node_name(text)
	node.title = node.title.trim_suffix("_")
	node.name = text
	node.add_child(Label.new())
	node.set_slot(0, true, 1, Color(1,1,1,1), true, 1, Color(1,1,1,1))
	node.offset.x -= position.x
	node.offset.y -= position.y
	add_child(node)

func get_unique_nodes() -> Array:
	#This function returns the names of the states in the graph
	var arr : Array = []
	for child in get_children():
		if child is GraphNode:
			if not child.name.begins_with("@"):
				arr.append(child.name)
	return arr
	
func popup_add_menu(position):
	last_mouse_pos = position
	$States.rect_position = last_mouse_pos
	$States.popup()

func _on_StatesGraphEdit_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)

func _on_StatesGraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot )

func _on_StatesGraphEdit_popup_request(position):
	popup_add_menu(position)

func _on_States_id_pressed(id):
	var node_start_pos = -(scroll_offset + (last_mouse_pos - rect_global_position))/zoom 
	add_state($States.get_item_text(id), node_start_pos)




func _on_StatesGraphEdit_delete_nodes_request():
	for nodes in get_children():
		if nodes is GraphNode:
			if nodes.selected:
				var all_connections : Array = get_connection_list()
				for connection in all_connections:
					var from_port = connection.get("from_port")
					var from = connection.get("from")
					var to_port = connection.get("to_port")
					var to = connection.get("to")
					if (nodes.name == from or nodes.name == to):
						disconnect_node(from,from_port,to,to_port)
				if is_instance_valid(nodes):
					nodes.clear_all_slots()
					nodes.queue_free()
					update()
