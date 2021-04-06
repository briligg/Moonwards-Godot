extends Spatial


export(PackedScene) var android_scene


var ready_once : bool = true
func _ready() -> void :
	if ready_once :
		#Be sure that the listening node actually hears my creation.
		call_deferred("_ready_deferred")

func _ready_deferred() -> void :
	var hud_sig : HudSignals = Signals.Hud
	hud_sig.emit_signal(hud_sig.ANDROID_SPOT_CREATED, self, "Hab Android")

#Create a new Android and add it as a child.
func get_android() -> ActorEntity :
	var instance : ActorEntity = android_scene.instance()
	add_child(instance)
	return instance
