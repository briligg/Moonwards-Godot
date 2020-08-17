extends RayCast


onready var viewport : Viewport = get_tree().root

func _physics_process(_delta) -> void :
	#Look for collisions so I can convert them to clicks.
	force_raycast_update()
	if is_colliding() :
		var collider = get_collider()
		if collider.has_signal("input_event") :
			#Create a new event for the object to read. 
			#I am emulating a mouse cursor.
			var new_event : InputEventMouse 
			if Input.is_action_just_pressed("left_click") :
				#Set the InputEvent to left mouse button.
				new_event = InputEventMouseButton.new()
				new_event.button_index = BUTTON_LEFT
			else :
				new_event = InputEventMouseMotion.new()
			get_collider().emit_signal("input_event", null, new_event, get_collision_point(), get_collision_normal(), null)

func _ready() :
	set_physics_process(false)

func activate() -> void :
	set_physics_process(true)

func deactivate() -> void :
	set_physics_process(false)
