extends Control

var is_all: bool = false
var entry_counter: int = 0
const MAX_ENTRIES: int = 6
const STD_MARGIN = 60

onready var main_area = $VBoxContainer/MainArea
onready var scroll_all = _build_all()

signal sequence_finished(idx)


var entries: Array = [
	{"name": "Diane Osborne",
	"sound": "dianeosborne.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalksi",
	"sound": "jankowalski.wav"},
]


func _ready():
	connect("sequence_finished", self, "_on_sequence_finished")
	emit_signal("sequence_finished", 0)


func _on_sequence_finished(idx) -> void:
	var first_entry: int = idx
	var last_entry: int = min(first_entry + MAX_ENTRIES, entries.size())


func _build_buttons() -> void:
	var i: int = 0
	var j: int = 0
	var containers: Array = [ceil(entries.size())]
	
	while i <= entries.size():
		#var c: VBoxContainer = VBoxContainer.new()
		pass
	
	
#	for e in entries:
#		var button: Button = Button.new()
#		button.text = e["name"]
#		button.margin_bottom = STD_MARGIN


func _build_button(var e: Dictionary) -> Button:
	var button: Button = Button.new()
	button.text = e["name"]
	button.rect_min_size = Vector2(360, 80)
	
	return button


func _build_all() -> ScrollContainer :
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.rect_min_size = Vector2(1920, 960)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.rect_min_size = Vector2(1920, 960)
	
	for e in entries:
		var button: Button = _build_button(e)
		vbox.add_child(button)
	
#	vbox.separation = 12
	scroll.add_child(vbox)
	$VBoxContainer.add_child(scroll)
	scroll.hide()
	
	return scroll


func _on_ShowAll_button_up():
	if(not is_all):
		main_area.hide()
		scroll_all.show()
		is_all = true
	else:
		main_area.show()
		scroll_all.hide()
		is_all = false
