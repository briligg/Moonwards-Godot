extends Control

var is_all: bool = false
var idx: int = 0

const MAX_ENTRIES: int = 5
const ANIMATION_LENGTH: float = 18.0

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
	{"name": "Jan Kowalski",
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
	_on_animation_finished("")


func _on_animation_finished(_name: String) -> void:
	for c in containers:
		c.hide()
	
	containers[idx].show()
	animation_players[idx].play("animation")
	
	idx += 1
	if idx >= containers.size():
		idx = 0


func _build_sequence_buttons() -> void:
	var i: int = 0
	var j: int = -1
	var c: Control = null
	var sequence_animation: AnimationPlayer = null
	var animation: Animation = null
	
	for e in entries:
		if i % MAX_ENTRIES == 0:
			j += 1
			c = Control.new()
			c.add_constant_override("separation", 64)
			sequence_animation = AnimationPlayer.new()
			sequence_animation.name = "AnimationPlayer"
			sequence_animation.connect("animation_finished", self, "_on_animation_finished")
			animation = Animation.new()
			animation.length = ANIMATION_LENGTH
			
			sequence_animation.add_animation("animation", animation)
			
			animation_players.append(sequence_animation)
			c.add_child(sequence_animation)
			
			containers.append(c)
			sequence_area.add_child(c)
		

		containers[j].add_child(_build_button(e, true, animation, i, j))
		i += 1


func _build_button(var e: Dictionary, var is_animated: bool,
		 var animation: Animation, var i: int, var j: int) -> Button:
	
	var button: Button = Button.new()
	button.text = e["name"]
	button.rect_min_size = Vector2(360, 80)
	button.theme = monument_theme
	button.set("custom_fonts/font", monument_font)
	button.rect_position = Vector2(-600, -600)
	
	if is_animated and animation != null:
		button.name = "Button" + str(i)
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, button.name + ":rect_position")
		if i % 2 == 0:
			animation.track_insert_key(track_index, 0.0, Vector2(-500, (i-j*MAX_ENTRIES)*150))
			animation.track_insert_key(track_index, ANIMATION_LENGTH, Vector2(2100, (i-j*MAX_ENTRIES)*150))
		else:
			animation.track_insert_key(track_index, 0.0, Vector2(2100, (i-j*MAX_ENTRIES)*150))
			animation.track_insert_key(track_index, ANIMATION_LENGTH, Vector2(-500, (i-j*MAX_ENTRIES)*150))
	return button


func _build_all() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.rect_min_size = Vector2(1920, 960)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.rect_min_size = Vector2(1920, 960)
	
	for e in entries:
		var button: Button = _build_button(e, false, null, 0, 0)
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
