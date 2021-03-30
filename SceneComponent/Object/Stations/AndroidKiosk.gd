extends Spatial



func _interaction(interactor : AEntity) -> void :
	var signals : HudSignals = Signals.Hud
	signals.emit_signal(signals.ANDROID_KIOSK_INTERACTED, interactor)

func _ready() -> void :
	$Interactable.connect("interacted_by", self, "_interaction")
