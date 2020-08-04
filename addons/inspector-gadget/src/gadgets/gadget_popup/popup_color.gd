extends AcceptDialog
class_name PopupColor
signal color_changed(color)

func _enter_tree():
	window_title = "Pick a color"
	var picker = ColorPicker.new()
	picker.connect("color_changed", self, "_on_color_changed")
	add_child(picker)

func _on_color_changed(color : Color):
	emit_signal("color_changed", color)
