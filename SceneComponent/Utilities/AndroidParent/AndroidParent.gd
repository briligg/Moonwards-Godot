extends Spatial


onready var android : ActorEntity = $Android

signal android_returned()
signal android_taken()

var ready_once : bool = true
func _ready() -> void :
	if ready_once :
		#Be sure that the listening node actually hears my creation.
		call_deferred("_ready_deferred")
		
		var comp : ControllableBodyComponent = android.get_component("ControllableBodyComponent")
		comp.connect("control_lost", self, "emit_signal", ["android_returned"])
		comp.connect("control_taken", self, "emit_signal", ["android_taken"])

func _ready_deferred() -> void :
	var hud_sig : HudSignals = Signals.Hud
	hud_sig.emit_signal(hud_sig.ANDROID_SPOT_CREATED, self, android, "Hab Android")
