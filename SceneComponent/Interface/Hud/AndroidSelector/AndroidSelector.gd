extends Control


onready var parent : AppContainer = get_parent()

func _ready():
	var sig : HudSignals = Signals.Hud
	sig.connect(sig.ANDROID_KIOSK_INTERACTED, self, "_sig_display")

func _sig_display(_interactor : AEntity) -> void :
	parent.change_app(self.get_name(), true)
