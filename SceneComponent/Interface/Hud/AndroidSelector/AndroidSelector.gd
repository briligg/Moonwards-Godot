extends Control


var interactor : AEntity

onready var parent : AppContainer = get_parent()
onready var showcase : Panel = $AndroidSpotShowcase

func _ready():
	var sig : HudSignals = Signals.Hud
	sig.connect(sig.ANDROID_KIOSK_INTERACTED, self, "_sig_display")
	
	sig.connect(sig.ANDROID_SPOT_CREATED, self, "_spot_created")

func android_selected(android) -> void :
	var interactable : Interactable = android.get_component("ControllableBodyComponent").get_node("Interactable")
	var interactor_comp : InteractorComponent = interactor.get_component("Interactor")
	interactor_comp.player_requested_interact(interactable)
	parent.revert_active_app()

func _sig_display(_interactor : AEntity) -> void :
	interactor = _interactor
	parent.change_app(self.get_name(), true)

func _spot_created(spatial : Spatial, android : ActorEntity, text : String) -> void :
	showcase.add_spot(android, text)
