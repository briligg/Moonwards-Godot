extends Spatial


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Area").connect("input_event", self, "on_input_event")

func on_input_event(_camera, event, click_pos, _click_normal, _shape_idx):
	if event is InputEventMouseButton && event.pressed :
		Log.warning(self, "" , "Tooltip question mark received a click")
		
