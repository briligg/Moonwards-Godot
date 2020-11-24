extends Spatial

func _ready() -> void:
	Signals.Loading.emit_signal(Signals.Loading.WORLD_ON_READY)
