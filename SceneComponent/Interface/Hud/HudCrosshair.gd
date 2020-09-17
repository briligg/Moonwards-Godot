extends TextureRect


var camera : Camera

#Determines when I am active or not.
var is_active : bool = false

#How many click events are currently possible.
#Animation will play until the integer is set to zero.
var clicks_possible : int = 0

onready var ray_cast : RayCast = get_node("ClickableRayCast")


#Called by signal. A click event is possible. Makes sure that no click event is possible before shutting off animation.
func _click_possible(click_is_possible : bool) -> void :
	if click_is_possible :
		clicks_possible += 1
		$Tree.active = true
		
	else :
		# warning-ignore:narrowing_conversion
		clicks_possible = max(clicks_possible - 1, 0)
		
		if clicks_possible == 0 :
			$Tree.active = false
			modulate = Color(1,1,1,1)
			rect_rotation = 0
			rect_pivot_offset = Vector2(5,5)
			margin_bottom = 5
			margin_top = -5
			margin_left = -5
			margin_right = 5

#Hide or show myself based on mouse captured state while in first person.
func _mouse_capture_set(is_captured : bool) -> void :
	#Do not show myself unless in first person mode.
	if not is_active :
		return
	
	if is_captured :
		show()
		ray_cast.enable()
	else :
		hide()
		ray_cast.disable()

func _physics_process(_delta) -> void :
	var current_camera : Camera = get_tree().root.get_camera()
	if current_camera != camera :
		camera = current_camera
		ray_cast.get_parent().remove_child(ray_cast)
		current_camera.add_child(ray_cast)
		
		#Make sure Ray Cast has 0,0,0 transformation so it is directly
		#on it's camera parent.
		ray_cast.transform.origin = Vector3.ZERO

# Listen to SignalsManager to see when I should activate/deactivate.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.SET_FIRST_PERSON, self, "_set_crosshair")
	Signals.Hud.connect(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_CLICK, self, "_click_possible")
	
	#This hides me when in first person mode and the mouse is active.
	Signals.Menus.connect(Signals.Menus.SET_MOUSE_TO_CAPTURED, self, "_mouse_capture_set")

# Determines if I should turn on when requested or not.
func _set_crosshair(activity_set : bool) -> void :
	is_active = activity_set
	if activity_set :
		show()
		Helpers.capture_mouse(true)
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		ray_cast.enable()
	else :
		hide()
		ray_cast.disable()
