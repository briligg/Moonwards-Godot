extends MenuButton
class_name DropDown


func _ready():
	get_popup().connect("id_pressed", self, "change_label")
	text = "Select a property"
func change_label(id : int):
	text = get_popup().get_item_text(id)
