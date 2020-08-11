extends VBoxContainer


func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.FLIGHT_VALUE_SET, self, "_set_value")

func _set_value(new_value : float) -> void :
	$ProgressBar.value = new_value
	$Anim.seek(0, true)
	$Anim.play("FadeOut")
