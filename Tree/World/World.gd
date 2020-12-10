extends Spatial

func _ready() -> void:
	Signals.Loading.emit_signal(Signals.Loading.WORLD_ON_READY)
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "idle_frame")
	Signals.Loading.emit_signal(Signals.Loading.WORLD_POST_READY)
	
