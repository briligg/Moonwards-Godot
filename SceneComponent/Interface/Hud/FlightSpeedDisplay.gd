extends VBoxContainer

const BASE_ADDITION : float = 100.0


func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.FLIGHT_VALUE_SET, self, "_set_value")

#Set the value of the progress bar. 
func _set_value(new_value : float) -> void :
	if new_value < $ProgressBar.max_value :
		#Make new_value increase quicker when at lower 
		var value : float = min(new_value, BASE_ADDITION)
		var total : float = max(new_value, BASE_ADDITION)
		var percent : float = value / total
		new_value += lerp(value, BASE_ADDITION, percent)
	
	$ProgressBar.value = new_value
	$Anim.seek(0, true)
	$Anim.play("FadeOut")
