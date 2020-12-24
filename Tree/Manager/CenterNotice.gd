extends Panel


func _pressed() -> void :
	deactivate()

func _ready() -> void  :
	$Button.connect("pressed", self, "_pressed")

func activate() -> void :
	get_parent().get_node("MouseBlock").show()
	show()

func deactivate() -> void :
	get_parent().get_node("MouseBlock").hide()
	hide()

func set_text(new_text : String) -> void :
	$Text.text = new_text
