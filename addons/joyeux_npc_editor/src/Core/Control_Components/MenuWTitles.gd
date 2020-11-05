tool
extends MenuButton
class_name DropDown
signal selected_type()
var is_enum : bool = false
var index : int = 0

func _ready():
	get_popup().connect("id_pressed", self, "change_label")
	get_popup().connect("index_pressed", self, "_on_index_changed")
	text = "Select a property"
	
func set_index(id):
	index = id
	change_label(id)

func change_label(id : int):
	text = get_popup().get_item_text(id)
	emit_signal("selected_type", get_meta(text))

func _on_index_changed(id):
	index = id
