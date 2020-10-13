extends Panel


func _ready() -> void :
	get_parent().get_node("HBoxContainer3/Button").connect("pressed", self, "_toggle")

func _toggle() -> void :
	visible = !visible
