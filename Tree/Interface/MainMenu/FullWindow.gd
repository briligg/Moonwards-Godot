extends Tabs


#Bring up the starting menu if a fullscreened app is closed.
func _ready() -> void :
	$NPCEditor.connect("closed", self, "_app_closed")

func _app_closed() -> void :
	get_parent().back_to_start_menu()

#Change which control node is shown.
func change_tab(tab_name : String) -> void :
	#Make sure that tab_name matches the name of the node(in editor)
	#that you are switching to.
	assert(has_node(tab_name))
	current_tab = get_node(tab_name).get_position_in_parent()
