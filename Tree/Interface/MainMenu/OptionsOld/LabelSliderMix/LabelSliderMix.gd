extends HBoxContainer

signal changed(val)

export(bool) var enabled = true setget set_enabled
export(String) var label = "Label"
export(int) var mi = 1
export(int) var ma = 100
export(int) var ticks = 10
export(int) var step = 1

var value = ma setget set_value, get_value

var oldvalue = value
var mouse_active = false

func set_value(val):
	$OptionSlider.value = val
	$OptionInput.value = val

func get_value():
	value = $OptionInput.value
	return value

func _ready():
	$OptionLabel.text = label
	$OptionSlider.min_value = mi
	$OptionSlider.max_value = ma
	$OptionSlider.step = step
	$OptionSlider.tick_count = ticks
	
	$OptionInput.min_value = mi
	$OptionInput.max_value = ma
	$OptionInput.step = step
	
	$OptionInput.share($OptionSlider)
	$OptionSlider.connect("value_changed", self, "notify_changed")
	
	set_enabled(enabled)
	
	connect("changed", self, "debug_value")

func debug_value(val):
	print("LabelSliderMix(%s) new value %s" % [get_path(), val])

func notify_changed(val):
	if not mouse_active:
		emit_signal("changed", val)

func set_enabled(state):
	$OptionSlider.scrollable = state
	$OptionSlider.editable = state
	$OptionInput.editable = state

func _input(event):
	if event.is_class("InputEventMouseButton"):
		if event.is_pressed():
			oldvalue = get_value()
			mouse_active = true
		else:
			mouse_active = false
			if oldvalue != get_value():
				notify_changed(value)
