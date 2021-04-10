extends OptionButton


signal low_selected()
signal high_selected()

func _item_selected(index : int) -> void :
	if index == 0 :
		emit_signal("low_selected")
	else :
		emit_signal("high_selected")

#Setup the options button and handle toggling options.
func _ready() -> void :
	add_item("Low", 0)
	add_item("High", 1)
	
	connect("item_selected", self, "_item_selected")
