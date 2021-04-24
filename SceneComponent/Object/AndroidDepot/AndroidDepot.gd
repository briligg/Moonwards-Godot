extends Spatial



export var spot_title : String = "Android Depot Android"


func _ready() -> void :
	var hud_sig : HudSignals = Signals.Hud
	for child in $Holder.get_children() :
		hud_sig.emit_signal(hud_sig.ANDROID_SPOT_CREATED, child,  spot_title)
