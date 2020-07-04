extends Control

var is_all: bool = false

const MAX_ENTRIES: int = 6

onready var sequence_area = $VBoxContainer/SequenceArea
onready var all_area = $VBoxContainer/AllArea
onready var monument_theme = load("res://SceneComponent/Display/MakersMonument/Monument.tres")
var monument_font: DynamicFont = DynamicFont.new()

signal sequence_finished(idx)


var entries: Array = [
	{"name": "Diane Osborne",
	"sound": "dianeosborne.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalski",
	"sound": "jankowalski.wav"},
	{"name": "Jan Kowalki",
	"sound": "jankowalski.wav"},
]


func _ready():
	connect("sequence_finished", self, "_on_sequence_finished")
	#emit_signal("sequence_finished", 0)
	monument_font = DynamicFont.new()
	monument_font.font_data = load("res://Assets/Interface/Fonts/Exo2/Exo2-ExtraBoldItalic.ttf")
	monument_font.size = 82
	
	$VBoxContainer/BottomArea/CenterContainer/ShowAll.set("custom_fonts/font", monument_font)
	monument_font.size = 64
	_build_all()


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
	button.theme = monument_theme
	button.set("custom_fonts/font", monument_font)
	
	return button


func _build_all() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.rect_min_size = Vector2(1920, 960)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.rect_min_size = Vector2(1920, 960)
	
	for e in entries:
		var button: Button = _build_button(e)
		vbox.add_child(button)
	
#	vbox.separation = 12
	scroll.add_child(vbox)
	all_area.add_child(scroll)


func _on_ShowAll_button_up():
	if(not is_all):
		sequence_area.hide()
		all_area.show()
		is_all = true
	else:
		sequence_area.show()
		all_area.hide()
		is_all = false
