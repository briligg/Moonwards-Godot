extends Spatial


export(PackedScene) var android_scene

export(String) var button_title = "Spawn Android somewhere"


func _android_control_lost(android : ActorEntity) -> void :
	android.queue_free()

var ready_once : bool = true
func _ready() -> void :
	if ready_once :
		#Be sure that the listening node actually hears my creation.
		call_deferred("_ready_deferred")

func _ready_deferred() -> void :
	var hud_sig : HudSignals = Signals.Hud
	hud_sig.emit_signal(hud_sig.ANDROID_SPOT_CREATED, self, button_title)

#Create a new Android and add it as a child.
func get_android() -> ActorEntity :
	var instance : ActorEntity = android_scene.instance()
	add_child(instance)
	
	#Listen for when you lose control of the android so that we can remove it.
	var comp : ControllableBodyComponent = instance.get_component("ControllableBodyComponent")
	comp.connect("control_lost", self, "_android_control_lost", [instance])
	
	return instance
