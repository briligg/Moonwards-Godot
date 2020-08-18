extends RayCast


onready var viewport : Viewport = get_tree().root

func _unhandled_input(event) -> void :
	#Look for collisions so I can convert them to clicks.
	if is_colliding() :
		var collider = get_collider()
		if collider.has_signal("input_event") :
			#Create a new event for the object to read. 
			#I am emulating a mouse cursor.
			var new_event : InputEventMouse 
			if event.is_action_pressed("left_click") :
				#Set the InputEvent to left mouse button.
				new_event = InputEventMouseButton.new()
				new_event.button_index = BUTTON_LEFT
				new_event.button_mask = BUTTON_MASK_LEFT
				new_event.pressed = true
				new_event.command = false
				new_event.device = 0
				new_event.factor = 1
				new_event.doubleclick = false
			else :
				new_event = InputEventMouseMotion.new()
				
			var camera : Camera = get_tree().root.get_camera()
			get_collider().emit_signal("input_event", camera, new_event, get_collision_point(), get_collision_normal(), 0)

func _ready() :
	set_process_unhandled_input(false)

func activate() -> void :
	set_process_unhandled_input(true)

func deactivate() -> void :
	set_process_unhandled_input(false)
