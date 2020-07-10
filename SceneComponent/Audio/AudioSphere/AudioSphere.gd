extends Interactable
"""
Groups: SoloAudioPlayer
"""

export var audio_file : AudioStreamOGGVorbis = AudioStreamOGGVorbis.new()

func _ready() -> void :
	#Will crash if no file is given to the AudioSphere.
	assert(audio_file.resource_path != "")
	
	audio_file.loop = false
	$Audio.stream = audio_file

#warning-ignore:unused_argument
func _play_sound(interactor_ray_cast):
	#Player requested audio. Play the audio.
	Signals.Audio.emit_signal(Signals.Audio.SOLO_AUDIO_STREAM_BEGUN)
	$Audio.play()
	
	#Start listening for other solo audio players to play.
	Signals.Audio.connect(Signals.Audio.SOLO_AUDIO_STREAM_BEGUN, self, "_stop")

func _stop() -> void :
	Signals.Audio.disconnect(Signals.Audio.SOLO_AUDIO_STREAM_BEGUN, self, "_stop")
	
	#Stop playing.
	$Audio.stop()
	
	#Let Signals know that I have ended.
	Signals.Audio.emit_signal(Signals.Audio.SOLO_AUDIO_STREAM_ENDED)
