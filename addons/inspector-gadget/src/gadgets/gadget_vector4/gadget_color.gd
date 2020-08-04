class_name GadgetColor
extends GadgetVector4
tool

func _set_colorbox() -> StyleBoxFlat:
	var colorbox :StyleBoxFlat= StyleBoxFlat.new()
	colorbox.border_color = Color(0.301961, 0.298039, 0.34902)
	colorbox.set_corner_radius_all(1)
	colorbox.set_border_width_all(1)
	return colorbox
	
func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "").(in_node_path, in_subnames):
	x_axis = "r"
	y_axis = "g"
	z_axis = "b"
	w_axis = "a"
	yield(self, "ready")
	var button = Button.new()
	button.text = "Pick"
	var popup = PopupColor.new()
	var colorbox :StyleBoxFlat = _set_colorbox()
	button.connect("pressed", popup, "popup_centered")
	get_node("HBoxContainer").add_child(button)
	popup.connect("color_changed", self, "populate_value")
	button.add_stylebox_override("normal", colorbox)
	button.add_stylebox_override("pressed", colorbox)
	button.add_stylebox_override("focus", colorbox)
	button.add_stylebox_override("hover", colorbox)
	button.rect_min_size = Vector2(50,10)
	popup.connect("color_changed", colorbox, "set_bg_color")
	add_child(popup)
	get_node("HBoxContainer").move_child(button, 0)
	
static func supports_type(value) -> bool:
	return value is Color

