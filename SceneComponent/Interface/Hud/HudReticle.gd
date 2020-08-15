extends TextureRect


#Listen for calls to show myself.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.SHOW_RETICLE, self, "show")
	Signals.Hud.connect(Signals.Hud.HIDE_RETICLE, self, "hide")
