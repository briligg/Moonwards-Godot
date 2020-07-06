extends Control

var is_all: bool = false

const MAX_ENTRIES: int = 6

onready var sequence_area: Control = $VBoxContainer/SequenceArea
onready var all_area: Control = $VBoxContainer/AllArea

onready var monument_theme = load("res://SceneComponent/Display/MakersMonument/Monument.tres")

var monument_font: DynamicFont = DynamicFont.new()
var containers: Array = []
var animation_players: Array = []

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
	
	monument_font = DynamicFont.new()
	monument_font.font_data = load("res://Assets/Interface/Fonts/Exo2/Exo2-ExtraBoldItalic.ttf")
	monument_font.size = 82
	
	$VBoxContainer/BottomArea/CenterContainer/ShowAll.set("custom_fonts/font", monument_font)
	monument_font.size = 64
	
	_build_all()
	_build_sequence_buttons()
	emit_signal("sequence_finished", 0)


func _on_sequence_finished(idx) -> void:
	for c in containers:
		c.hide()
	
	containers[idx].show()
	animation_players[idx].play("animation")


func _build_sequence_buttons() -> void:
	var i: int = 0
	var j: int = -1
	var c: VBoxContainer = null
	var sequence_animation: AnimationPlayer = null
	var animation: Animation = null
	
	for e in entries:
		if i % MAX_ENTRIES == 0:
			j += 1
			c = VBoxContainer.new()
			c.add_constant_override("separation", 64)
			sequence_animation = AnimationPlayer.new()
			animation = Animation.new()
			animation.length = 16.0
			
			sequence_animation.add_animation("animation", animation)
			
			animation_players.append(sequence_animation)
			c.add_child(sequence_animation)
			
			containers.append(c)
			sequence_area.add_child(c)
		
		containers[j].add_child(_build_button(e, true, sequence_animation, animation))
		i += 1


func _build_button(var e: Dictionary, var is_animated: bool,
		 var sequence_animation: AnimationPlayer, var animation: Animation) -> Button:
	
	var button: Button = Button.new()
	button.text = e["name"]
	button.rect_min_size = Vector2(360, 80)
	button.theme = monument_theme
	button.set("custom_fonts/font", monument_font)
	
	if is_animated and sequence_animation != null and animation != null:
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, button.name + ":rect_position")
		animation.track_insert_key(track_index, 0.0, Vector2(0, 0))
		animation.track_insert_key(track_index, 16.0, Vector2(2600, 0))
		sequence_animation.add_animation("animation", animation)
	
	return button


func _build_all() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.rect_min_size = Vector2(1920, 960)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.rect_min_size = Vector2(1920, 960)
	
	for e in entries:
		var button: Button = _build_button(e, false, null, null)
		vbox.add_child(button)
	
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
