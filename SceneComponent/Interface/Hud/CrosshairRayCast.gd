extends RayCast


onready var viewport : Viewport = get_tree().root

func _input(event) -> void :
	if !(event is InputEventMouseButton):
		return

	#Look for collisions so I can convert them to clicks.
	if is_colliding():
		var collider = get_collider()
		if collider.has_signal("input_event") :
			var camera : Camera = get_tree().root.get_camera()
			get_collider().emit_signal("input_event", camera, event, get_collision_point(), get_collision_normal(), 0)

func _ready() :
	set_process_unhandled_input(false)

func enable() -> void :
	set_process_unhandled_input(true)

func disable() -> void :
	set_process_unhandled_input(false)
