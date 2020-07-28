extends GraphEdit

var last_mouse_pos : Vector2 = Vector2.ZERO
func _ready():
	pass # Replace with function body.
	
func add_state(text : String, position : Vector2 = Vector2.ZERO):
	var node : GraphNode = GraphNode.new()
	node.title = text
	node.add_child(Label.new())
	node.set_slot(0, true, 1, Color(1,1,1,1), true, 1, Color(1,1,1,1))
	node.offset.x -= position.x
	node.offset.y -= position.y
	add_child(node)
	
	
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
	var node_start_pos =  -(scroll_offset + (last_mouse_pos - rect_global_position)) 
	add_state($States.get_item_text(id), node_start_pos)


