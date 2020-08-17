tool
extends GraphEdit


func _on_GraphEdit_popup_request(position):
	create_node()


func _on_GraphEdit_delete_nodes_request():
	pass # Replace with function body.


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	pass # Replace with function body.


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	pass # Replace with function body.

func create_node(text: String = "", input : String = "", override : String = "", offset : Vector2 = Vector2.ZERO):
	var node = GraphNode.new()
	var text_popup = TextPopup.new(text, input, override)
	node.offset = offset
	node.title = text
	var popbutton = Button.new()
	popbutton.text = "Edit"
	popbutton.connect("pressed", text_popup, "popup")
	node.add_child(popbutton)
	node.add_child(text_popup)
	add_child(node)
