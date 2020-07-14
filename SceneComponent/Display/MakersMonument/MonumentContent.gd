extends Control

var is_all: bool = false
var idx: int = 0

const MAX_ENTRIES: int = 5
const ANIMATION_LENGTH: float = 18.0 #18.0
const TIME_DELAY: float = 6.8 #6.8
const Y_SEPARATOR: int = 180

onready var sequence_area: Control = $VBoxContainer/SequenceArea
onready var all_area: Control = $VBoxContainer/AllArea

const AUDIO_PATH: String = "res://Assets/Sounds/Monument/"
onready var audio_player: AudioStreamPlayer = $AudioPlayer

var containers: Array = []
var animation_players: Array = []

signal entry_selected

var entries: Array = [
	{"name": "Diane Osborne",
	"sound": "test.ogg"},
	{"name": "Stanislaw Lem",
	"sound": "test.ogg"},
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

func _ready() -> void:
	_build_all()
	_build_sequence_buttons()
	
	for c in containers:
		c.hide()
		
	containers[idx].show()


func play() -> void:
	animation_players[idx].play("animation")


func stop() -> void:
	animation_players[idx].stop(false)


func _on_animation_finished(_name: String) -> void:
	for b in containers[idx].get_children():
		if b.is_class("Button"):
			b.disconnect("button_up", self, "_on_button_up")
	
	for c in containers:
		c.hide()
	
	idx += 1
	if idx >= containers.size():
		idx = 0
	
	containers[idx].show()
	animation_players[idx].play("animation")


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
			sequence_animation = AnimationPlayer.new()
			sequence_animation.name = "AnimationPlayer"
			sequence_animation.connect("animation_finished", self, "_on_animation_finished")
			animation = Animation.new()
			animation.length = ANIMATION_LENGTH + (MAX_ENTRIES-1) * TIME_DELAY
			
			sequence_animation.add_animation("animation", animation)
			
			animation_players.append(sequence_animation)
			c.add_child(sequence_animation)
			
			containers.append(c)
			sequence_area.add_child(c)
		
		_build_button(e, true, animation, containers[j], i, j)
		i += 1


func _build_all() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.rect_min_size = Vector2(1920, 960)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.rect_min_size = Vector2(1920, 960)
	
	for e in entries:
		_build_button(e, false, null, vbox, 0, 0)
	
	scroll.add_child(vbox)
	all_area.add_child(scroll)


func _build_button(e: Dictionary, is_animated: bool, animation: Animation,
		parent: Control, i: int, j: int) -> void:
	
	var button: Button = Button.new()
	parent.add_child(button)
	button.text = e["name"]
	button.connect("button_up", self, "_on_button_up", [e["sound"]])
	
	if is_animated and animation != null:
		button.rect_position = Vector2(-ProjectSettings.get_setting("display/window/size/width"),
				-ProjectSettings.get_setting("display/window/size/height"))
		button.name = "Button" + str(i)
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, button.name + ":rect_position")
		var delay_idx = i-j*MAX_ENTRIES
		if i % 2 == 0:
			animation.track_insert_key(track_index, delay_idx*TIME_DELAY, Vector2(-button.rect_size.x, delay_idx*Y_SEPARATOR))
			animation.track_insert_key(track_index, ANIMATION_LENGTH+delay_idx*TIME_DELAY,
					Vector2(ProjectSettings.get_setting("display/window/size/width")+1, delay_idx*Y_SEPARATOR))
		else:
			animation.track_insert_key(track_index, delay_idx*TIME_DELAY,
					Vector2(ProjectSettings.get_setting("display/window/size/width")+1, delay_idx*Y_SEPARATOR))
			animation.track_insert_key(track_index, ANIMATION_LENGTH+delay_idx*TIME_DELAY, Vector2(-button.rect_size.x, delay_idx*Y_SEPARATOR))


func _on_ShowAll_button_up() -> void:
	if(not is_all):
		sequence_area.hide()
		all_area.show()
		animation_players[idx].stop(false)
		is_all = true
	else:
		sequence_area.show()
		all_area.hide()
		animation_players[idx].play("animation")
		is_all = false


func _on_button_up(sound: String) -> void:
	var stream = load(AUDIO_PATH + sound)
	if stream != null:
		if audio_player.playing:
			audio_player.stop()
		stream.loop = false
		audio_player.stream = stream
		audio_player.play()
	else:
		Log.warning(self, "_on_button_up", "Cannot load audio resource on path: "
				+ str(AUDIO_PATH + sound))
