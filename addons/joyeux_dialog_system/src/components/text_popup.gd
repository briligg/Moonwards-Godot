tool
extends WindowDialog
class_name TextPopup

var content : String= ""
var title : String = ""
var override : String = ""
var content_edit : Control = null
var title_edit : Control = null
var override_edit : Control = null

func _init(txt = "", cntnt = "", ov = ""):
	content = cntnt
	title = txt
	override = ov

func  _ready():
	resizable = true
	rect_min_size = Vector2(400, 400)
	
	var cont = VBoxContainer.new()
	cont.anchor_right = 0.99
	cont.anchor_left = 0.01
	cont.anchor_bottom = 0.99
	cont.anchor_top = 0.01
	cont.size_flags_horizontal = SIZE_EXPAND_FILL
	cont.size_flags_vertical = SIZE_EXPAND_FILL
	
	var label_cont = HBoxContainer.new()
	label_cont.size_flags_horizontal = SIZE_EXPAND_FILL
	var override_cont = HBoxContainer.new()
	override_cont.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var ov_label = Label.new()
	ov_label.text = "Name override (Leave empty if none): "
	
	override_edit = LineEdit.new()
	override_edit.text = override
	override_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var label = Label.new()
	label.text = "Title:"

	title_edit = LineEdit.new()
	title_edit.text = title
	title_edit.size_flags_horizontal = SIZE_EXPAND_FILL

	var label2 = Label.new()
	label2.text = "Dialog:"
	
	content_edit = TextEdit.new()
	content_edit.text = content
	content_edit.size_flags_vertical = SIZE_EXPAND_FILL
	content_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var accept = Button.new()
	accept.text = "Accept"
	
	var close = Button.new()
	close.text = "Cancel"
	accept.connect("pressed", self, "_on_Accept_pressed")
	close.connect("pressed", self, "_on_Cancel_pressed")
	
	var button_cont = HBoxContainer.new()
	button_cont.alignment = HBoxContainer.ALIGN_CENTER

	add_child(cont)
	cont.add_child(label_cont)
	
	label_cont.add_child(label)
	label_cont.add_child(title_edit)
	
	cont.add_child(override_cont)
	
	override_cont.add_child(ov_label)
	override_cont.add_child(override_edit)
	
	cont.add_child(HSeparator.new())
	cont.add_child(label2)
	cont.add_child(content_edit)
	cont.add_child(button_cont)
	
	button_cont.add_child(accept)
	button_cont.add_child(close)
	
func _on_Accept_pressed():
	hide()
	override = override_edit.text
	content = content_edit.text
	title = title_edit.text
	var parent = get_parent()
	if parent is GraphNode:
		parent.title = title

func _on_Cancel_pressed():
	hide()
	content_edit.text = content
	title_edit.text = title
	override_edit.text = override
