extends Button


func _pressed() -> void :
	get_tree().quit()
	
func _ready() -> void :
	connect("pressed", self, "_pressed")
