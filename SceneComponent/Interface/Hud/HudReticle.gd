extends TextureRect



#Determines if I should turn on when requested or not.
func _set_activity(is_active : bool) -> void :
	if is_active :
		Signals.Hud.connect(Signals.Hud.SHOW_RETICLE, self, "show")
		Signals.Hud.connect(Signals.Hud.HIDE_RETICLE, self, "hide")
	else :
		hide()
		Signals.Hud.disconnect(Signals.Hud.SHOW_RETICLE, self, "show")
		Signals.Hud.disconnect(Signals.Hud.HIDE_RETICLE, self, "hide")

#Listen to SignalsManager to see when I should activate/deactivate.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.RETICLE_ACTIVITY_SET, self, "_set_activity")
