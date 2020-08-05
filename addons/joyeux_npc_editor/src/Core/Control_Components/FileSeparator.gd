tool
extends HBoxContainer
class_name FileLabel


func _init(filters = ""):
	if filters != "":
		var button = Button.new()
		button.text = "Open..."
		button.name = "Button"
		var Dialog = FileDialog.new()
		Dialog.mode = 0
		Dialog.filters = filters.rsplit(",")
		Dialog.name = "OpenFile"
		Dialog.rect_min_size = Vector2(100,250)
		var text = LineEdit.new()
		text.name = "Text"
		text.editable = false
		add_child(button)
		add_child(text)
		add_child(Dialog)
	else:
		yield(self, "ready")
		var Dial = get_node("OpenFile")
		get_node("Button").connect("pressed", self, "open_file")
		Dial.connect("about_to_show", get_node("Text"), "clear")
		Dial.connect("file_selected",  get_node("Text"), "append_at_cursor")
		Dial.get_cancel().connect("pressed",  get_node("Text"), "clear")

func open_file():
	get_node("OpenFile").popup_centered()
