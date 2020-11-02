extends Control


signal app_changed(old_app, new_app)
signal app_reverted(old_app_being_reverted_to)

#Provide simple undo and switching functionality.
var current_app : Node = null
var previous_app : Node = null

#Blurred background reference for quick access.
onready var blur : TextureRect = get_node("../Blur")
#Lets us blur the background when reverting if needed.
var previous_app_blurred : bool = false

#Called from a signal. Determine if I should hide or view myself.
func _hud_visibility(_flag, become_visible : bool) -> void :
	if not Hud.has_flag(Hud.flags.AppMenusAll) :
		return
	
	visible = become_visible

#Look for the visible app and set it as current.
func _ready() -> void :
	for app in get_children() :
		if app.visible :
			current_app = app
			previous_app = app
			break
	
	#Hide myself if all apps are suppose to be hidden.
	Signals.Hud.connect(Signals.Hud.HIDDEN_HUDS_SET, self, "_hud_visibility", [false])
	Signals.Hud.connect(Signals.Hud.VISIBLE_HUDS_SET, self, "_hud_visibility", [true])

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
	
	#Let anything listening know the app has been changed.
	emit_signal("app_changed", previous_app, app_node)

#Go back to the previous app.
func revert_active_app() -> void :
	current_app.visible = false
	current_app = previous_app
	previous_app.visible = true
	
	blur.visible = previous_app_blurred
	
	emit_signal("app_reverted")
