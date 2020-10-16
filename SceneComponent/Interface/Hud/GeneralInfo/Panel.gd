extends PanelContainer


func _ready() -> void :
	get_parent().get_node("TopRight/Button").connect("pressed", self, "_toggle")

func _toggle() -> void :
	visible = !visible
