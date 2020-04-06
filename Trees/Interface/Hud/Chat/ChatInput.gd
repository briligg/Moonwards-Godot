extends LineEdit


func _gui_input(event):
	if not event is InputEventKey :
		return
	
	#Mark the received input as handled to prevent 
	#other nodes from reading it.
	get_tree().get_root().set_input_as_handled() 
