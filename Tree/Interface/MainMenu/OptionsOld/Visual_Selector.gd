extends Control
export(NodePath) var slot_option_path : NodePath = "../../../VBoxContainer/SlotOption"
onready var opt : OptionButton = get_node(slot_option_path)

func _ready() -> void:
	opt.emit_signal("item_selected",0)
func _on_pants_selected() -> void:
	opt.select(0)
	opt.emit_signal("item_selected",0)
func _on_shirt_selected() -> void:
	opt.select(1)
	opt.emit_signal("item_selected",1)
func _on_skin_selected() -> void:
	opt.select(2)
	opt.emit_signal("item_selected",2)
func _on_hair_selected() -> void:
	opt.select(3)
	opt.emit_signal("item_selected",3)
func _on_shoes_selected() -> void:
	opt.select(4)
	opt.emit_signal("item_selected",4)
