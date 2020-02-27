extends Spatial

signal activate_signal

func activate() -> void:
	emit_signal("activate_signal")
