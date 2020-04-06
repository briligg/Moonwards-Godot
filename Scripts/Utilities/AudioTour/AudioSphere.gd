extends "res://Scripts/Utilities/Interactable/Interactable.gd"
"""
Groups: SoloAudioPlayer
"""


export var audio_file : AudioStreamOGGVorbis = AudioStreamOGGVorbis.new()


func _ready() -> void :
	audio_file.loop = false
	$Audio.stream = audio_file


#warning-ignore:unused_argument
func play_sound(interactor_ray_cast):
	#Player requested audio. Play the audio.
	get_tree().call_group( "SoloAudioPlayer", "stop" )
	$Audio.play()


func stop() -> void :
	$Audio.stop()
