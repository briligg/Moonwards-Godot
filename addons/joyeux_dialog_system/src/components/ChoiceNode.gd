tool
extends GraphNode

enum {
	MULTIPLE,
	TEXT_INPUT
}

var interface_type : int = MULTIPLE 

func _ready() -> void:
	if interface_type == TEXT_INPUT:
		title = "Text input match"
	set_slot(0, true, TYPE_BOOL, Color(1,1,1,1), false, TYPE_BOOL, Color(1,1,1,1))

func set_options(options : Array) -> void:
	for opt in options:
		if opt is String:
			var line = LineEdit.new()
			line.text = opt
			set_slot(get_child_count()-1, false, TYPE_BOOL, Color(1,1,1,1), true, TYPE_BOOL, Color(1,1,1,1))
			add_child(line)
	move_child($Button, get_child_count())

func get_option(id : int) -> String:
	id += 1
	if id < get_child_count():
		return get_child(id).text
	return ""


func get_options() -> Array:
	var options : Array = []
	for child in get_children():
		if child is LineEdit:
			if child.text != "":
				options.append(child.text)
	return options

func _on_Button_pressed() -> void:
	set_slot(get_child_count()-1, false, TYPE_BOOL, Color(1,1,1,1), true, TYPE_BOOL, Color(1,1,1,1))
	add_child(LineEdit.new())
	move_child($Button, get_child_count())
