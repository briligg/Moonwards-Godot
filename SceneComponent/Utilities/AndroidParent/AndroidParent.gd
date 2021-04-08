extends Spatial

export var title : String = "Android"

#Create a spot on my own or not.
export var auto_spot_create : bool = true


onready var android : ActorEntity = $Android

signal android_returned()
signal android_taken()

func _android_returned() -> void :
	emit_signal("android_returned")

func _android_taken(_interactor : AEntity) -> void :
	emit_signal("android_taken")

var ready_once : bool = true
func _ready() -> void :
	if ready_once :
		#Be sure that the listening node actually hears my creation.
		call_deferred("_ready_deferred")
		
		var comp : ControllableBodyComponent = android.get_component("ControllableBodyComponent")
		comp.connect("control_lost", self, "_android_returned")
		comp.connect("control_taken", self, "_android_taken")
		
		ready_once = false

func _ready_deferred() -> void :
	if not auto_spot_create :
		return
	var hud_sig : HudSignals = Signals.Hud
	hud_sig.emit_signal(hud_sig.ANDROID_SPOT_CREATED, self,  title)

func request_android(_interactor : ActorEntity) -> ActorEntity :
	var interactor : InteractorComponent = _interactor.get_component("Interactor")
	var controllable : ControllableBodyComponent = android.get_component("ControllableBodyComponent")
	var interactable : Interactable = controllable.get_node("Interactable")
	interactor.player_requested_interact(interactable)
	
	return android
