extends Container


#Provide simple undo and switching functionality.
var current_app : Node = null
var previous_app : Node = null

#Blurred background reference for quick access.
onready var blur : TextureRect = get_node("../Blur")
#Lets us blur the background when reverting if needed.
var previous_app_blurred : bool = false

#Look for the visible app and set it as current.
func _ready() -> void :
	for app in get_children() :
		if app.visible :
			current_app = app
			previous_app = app
			break

#Change the active app by passing it's node name.
func change_app(app_name : String, blur_background : bool = false) -> void :
	assert(has_node(app_name))
	new_active_app(get_node(app_name), blur_background)

#A new app node has become active. Hide the previous app.
func new_active_app(app_node : Node, blurred_background : bool = false) -> void :
	current_app.hide()
	if app_node != current_app :
		previous_app = current_app
	current_app = app_node
	current_app.show()
	
	#Show the blurred background if specified.
	previous_app_blurred = blur.visible
	blur.visible = blurred_background

#Go back to the previous app.
func revert_active_app() -> void :
	current_app.visible = false
	current_app = previous_app
	previous_app.visible = true
	
	blur.visible = previous_app_blurred
