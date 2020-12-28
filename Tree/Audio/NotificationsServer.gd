extends Node

"""Local singleton for user notifications and global sounds"""

enum NOTIF_TYPE {
	ALERT,
	CHAT,
	WORLD	
}

const notif = [
 preload("res://Assets/Sounds/UI/UI_alert.ogg"), # alert_notif_sound 
 preload("res://Assets/Sounds/UI/UI_chat.ogg"), #chat_notif_sound
 preload("res://Assets/Sounds/UI/UI_world.ogg"), #world_notif_sound
]

var queue : Array = []
onready var Audio = AudioStreamPlayer.new()

func _ready():
	Audio.connect("finished", self, "_on_audio_finished")
	add_child(Audio)

func notif_sound(type : int, uses_queue : bool = false, prioritary : bool = false):
	if prioritary:
		Audio.stop()
		Audio.stream = notif[type]
		Audio.play()
	if Audio.playing:
		if uses_queue:
			queue.append(type)
			return
		else:
			return
	else:
		Audio.stream = notif[type]
		Audio.play()
		
func _on_audio_finished():
	if queue.size()>0:
		Audio.stream = notif[queue.pop_front()]
		Audio.play()
	else:
		return
