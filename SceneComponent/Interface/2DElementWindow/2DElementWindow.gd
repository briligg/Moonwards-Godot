extends CanvasLayer


func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.START_ELEMENT_WINDOW, self, "_start_element_window")

func _start_element_window(new_node : Node) -> void :
	Log.debug(self, "Start", str(new_node))
