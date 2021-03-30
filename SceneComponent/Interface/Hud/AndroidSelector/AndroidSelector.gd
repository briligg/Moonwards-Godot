extends Control


onready var parent : AppContainer = get_parent()
onready var showcase : Panel = $AndroidSpotShowcase

func _ready():
	var sig : HudSignals = Signals.Hud
	sig.connect(sig.ANDROID_KIOSK_INTERACTED, self, "_sig_display")
	
	sig.connect(sig.ANDROID_SPOT_CREATED, self, "_spot_created")

func _sig_display(_interactor : AEntity) -> void :
	parent.change_app(self.get_name(), true)

func _spot_created(spatial : Spatial, android : ActorEntity, color : Color) -> void :
	showcase.add_spot()
