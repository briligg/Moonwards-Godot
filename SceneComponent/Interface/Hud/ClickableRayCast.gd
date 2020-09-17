extends MouseSimulatingRayCast

onready var viewport : Viewport = get_tree().root


func _click_possible_status(_new_collider) -> void :
	if not _new_collider == null :
		 Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_CLICK, true)
	else : 
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_CLICK, false)

func _input(event) -> void :
	if !(event is InputEventMouseButton):
		return

	#Look for collisions so I can convert them to clicks.
	if is_colliding() :
		var collider = get_collider()
		if collider.has_signal("input_event") :
			var camera : Camera = get_tree().root.get_camera()
			get_collider().emit_signal("input_event", camera, event, get_collision_point(), get_collision_normal(), 0)

func _ready() :
	set_process_input(false)
	connect("collider_changed", self, "_click_possible_status")

func enable() -> void :
	set_process_input(true)

func disable() -> void :
	set_process_input(false)
