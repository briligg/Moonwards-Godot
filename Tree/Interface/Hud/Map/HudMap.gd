extends Panel


func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.MAP_VISIBILITY_SET, self, "_set_visibility")

func _set_visibility(become_visible : bool) -> void :
	visible = become_visible
