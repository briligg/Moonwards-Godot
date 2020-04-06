extends HBoxContainer

signal changed(val)

export(bool) var enabled = true setget set_enabled
export(String) var label = "Label"

var button

func set_value(val):
	$OptionButton.selected = val

func get_value():
	$OptionButton.selected

func _enter_tree():
	$OptionLabel.text = label

func _ready():
	button = $OptionButton
	$OptionButton.connect("item_selected", self, "notify_changed")
	set_enabled(enabled)
	connect("changed", self, "debug_value")

func debug_value(val):
	print("LabelOptionButton(%s) new value %s" % [get_path(), val])

func notify_changed(val):
	emit_signal("changed", $OptionButton.selected)

func set_enabled(state):
	$OptionButton.disabled = not state

func add_item(label, id=-1):
	$OptionButton.add_item(label, id)

#func _input(event):
