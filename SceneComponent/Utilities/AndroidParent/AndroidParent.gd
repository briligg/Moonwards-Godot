extends Spatial

var ready_once : bool = true
func _ready() -> void :
	if ready_once :
		#Be sure that the listening node actually hears my creation.
		call_deferred("_ready_deferred")

func _ready_deferred() -> void :
	var hud_sig : HudSignals = Signals.Hud
	hud_sig.emit_signal(hud_sig.ANDROID_SPOT_CREATED, self, $Android, Color(1,1,1))
