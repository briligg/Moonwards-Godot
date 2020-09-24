extends Container


#Provide simple undo and switching functionality.
var current_app : Node = null
var previous_app : Node = null


#Look for the visible app and set it as current.
func _ready() -> void :
	for app in get_children() :
		if app.visible :
			current_app = app
			previous_app = app
			break

#Change the active app by passing it's node name.
func change_app(app_name : String) -> void :
	assert(has_node(app_name))
	new_active_app(get_node(app_name))

#A new app node has become active. Hide the previous app.
func new_active_app(app_node : Node) -> void :
	current_app.hide()
	if app_node != current_app :
		previous_app = current_app
	current_app = app_node
	current_app.show()

#Go back to the previous app.
func revert_active_app() -> void :
	current_app.visible = false
	current_app = previous_app
	previous_app.visible = true
