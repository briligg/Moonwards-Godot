extends Button


#Bring up the Map display.
func _pressed() -> void :
	Signals.Hud.emit_signal(Signals.Hud.MAP_VISIBILITY_SET, true)

#Listen for when I am pressed.
func _ready() -> void :
	connect("pressed", self, "_pressed")
