extends RayCast


onready var viewport : Viewport = get_tree().root

var previous_collider = null

func _input(event) -> void :
	if !(event is InputEventMouseButton):
		return

	#Look for collisions so I can convert them to clicks.
	if is_colliding():
		var collider = get_collider()
		if collider.has_signal("input_event") :
			var camera : Camera = get_tree().root.get_camera()
			get_collider().emit_signal("input_event", camera, event, get_collision_point(), get_collision_normal(), 0)

#Determine when I am colliding. If I am, then let Hud know.
func _physics_process(_delta : float) -> void:
	if is_colliding() && get_collider().has_signal("input_event") && previous_collider != get_collider():
		previous_collider = get_collider()
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_CLICK, true)
	
	elif is_colliding() :
		pass
	
	else :
		previous_collider = null
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_CLICK, false)

func _ready() :
	set_process_unhandled_input(false)

func enable() -> void :
	set_process_unhandled_input(true)

func disable() -> void :
	set_process_unhandled_input(false)
