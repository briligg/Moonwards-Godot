extends TextureRect

#Determines when I am active or not.
var is_active : bool = false

#How many click events are currently possible.
#Animation will play until the integer is set to zero.
var clicks_possible : bool = false
var interacts_possible : bool = false

#Called by signal. A click event is possible. Makes sure that no click event is possible before shutting off animation.
func _click_possible(click_is_possible : bool, is_interactable : bool = false) -> void :
	#Add to the watching ints and enable cursor.
	if click_is_possible :
		if is_interactable :
			interacts_possible = true
		else :
			clicks_possible = true
		$Tree.active = true
		
	else :
		if is_interactable :
			# warning-ignore:narrowing_conversion
			interacts_possible = false
		else :
			# warning-ignore:narrowing_conversion
			clicks_possible = false
		
		#If there are no possible events to click, reset to neutral.
		if not clicks_possible  && not interacts_possible :
			$Tree.active = false
			modulate = Color(1,1,1,1)
			rect_rotation = 0
			rect_pivot_offset = Vector2(5,5)
			margin_bottom = 5
			margin_top = -5
			margin_left = -5
			margin_right = 5
	
	
	#If there is an Interactable present, animate for that.
	#Else animate for clicks possible
	if interacts_possible :
		$Tree.set("parameters/HighlightType/current", 1)
		
	elif clicks_possible :
		$Tree.set("parameters/HighlightType/current", 0)

#Hide or show myself based on mouse captured state while in first person.
func _mouse_capture_set(is_captured : bool) -> void :
	#Do not show myself unless in first person mode.
	if not is_active :
		return
	
	if is_captured :
		show()
	else :
		hide()

# Listen to SignalsManager to see when I should activate/deactivate.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.SET_FIRST_PERSON, self, "_set_crosshair")
	Signals.Hud.connect(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_CLICK, self, "_click_possible")
	Signals.Hud.connect(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, self, "_click_possible", [true])
	
	#This hides me when in first person mode and the mouse is active.
	Signals.Menus.connect(Signals.Menus.SET_MOUSE_TO_CAPTURED, self, "_mouse_capture_set")

# Determines if I should turn on when requested or not.
func _set_crosshair(activity_set : bool) -> void :
	is_active = activity_set
	if activity_set :
		show()
		Helpers.capture_mouse(true)
	else :
		hide()
