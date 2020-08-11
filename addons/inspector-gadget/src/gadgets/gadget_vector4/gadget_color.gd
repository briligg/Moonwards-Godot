class_name GadgetColor
extends GadgetVector4
tool

var colorbox : StyleBoxFlat = _set_colorbox()

func _set_colorbox() -> StyleBoxFlat:
	var colorbox :StyleBoxFlat= StyleBoxFlat.new()
	colorbox.border_color = Color(0.301961, 0.298039, 0.34902)
	colorbox.set_corner_radius_all(1)
	colorbox.set_border_width_all(1)
	return colorbox

func _set_button_stylebox(button, colorbox):
	button.add_stylebox_override("normal", colorbox)
	button.add_stylebox_override("pressed", colorbox)
	button.add_stylebox_override("focus", colorbox)
	button.add_stylebox_override("hover", colorbox)
	button.rect_min_size = Vector2(50,10)

func _init(in_node_path: NodePath = NodePath(), in_subnames: String = "").(in_node_path, in_subnames):
	x_axis = "r"
	y_axis = "g"
	z_axis = "b"
	w_axis = "a"
	yield(self, "ready")
	var button = Button.new()
	button.text = "Pick"
	
	var popup = PopupColor.new()
	popup.connect("color_changed", self, "set_node_value")
	get_node("HBoxContainer/FloatGadgetX").connect("value_changed", popup, "change_color_r")
	get_node("HBoxContainer/FloatGadgetY").connect("value_changed", popup, "change_color_g")
	get_node("HBoxContainer/FloatGadgetZ").connect("value_changed", popup, "change_color_b")
	get_node("HBoxContainer/FloatGadgetW").connect("value_changed", popup, "change_color_a")
	
	get_node("HBoxContainer/FloatGadgetX").connect("value_changed", self, "change_colorbox", ["r"])
	get_node("HBoxContainer/FloatGadgetY").connect("value_changed", self, "change_colorbox", ["g"])
	get_node("HBoxContainer/FloatGadgetZ").connect("value_changed", self, "change_colorbox", ["b"])
	get_node("HBoxContainer/FloatGadgetW").connect("value_changed", self, "change_colorbox", ["a"])
	
	button.connect("pressed", popup, "popup_centered")
	get_node("HBoxContainer").add_child(button)
	_set_button_stylebox(button, colorbox)
	
	
	connect("value_changed", colorbox, "set_bg_color")
	popup.connect("color_changed", colorbox, "set_bg_color")
	add_child(popup)
	get_node("HBoxContainer").move_child(button, 0)
	
func change_colorbox(color : float, type : String):
	var current : Color = colorbox.get_bg_color()
	match type:
		"r":
			current.r = color 
		"g":
			current.g = color 
		"b":
			current.b = color 
		"a":
			current.a = color 
	colorbox.set_bg_color(current)
	
static func supports_type(value) -> bool:
	return value is Color

