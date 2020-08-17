extends AcceptDialog
class_name PopupColor
var picker = ColorPicker.new()
signal color_changed(color)

func _enter_tree():
	window_title = "Pick a color"
	
	picker.connect("color_changed", self, "_on_color_changed")
	add_child(picker)

func _on_color_changed(color : Color):
	emit_signal("color_changed", color)

func change_color(color : Color):
	picker.color = color

func change_color_r(color : float):
	picker.color.r = color

func change_color_g(color : float):
	picker.color.g = color

func change_color_b(color : float):
	picker.color.b = color
	
func change_color_a(color : float):
	picker.color.a = color
