tool
extends AudioStreamPlayer3D

export(Array, AudioStream) var Sounds : Array = []

var first

func _ready():
	connect("finished", self, "_on_AudioStreamPlayer3D_finished")
	_shuffle_start()

func _shuffle_start():
	if Sounds.size() > 0:
		Sounds.shuffle()
		first = Sounds.front()
		stream = Sounds.pop_front()
		Sounds.append(first)
		play()

func _on_AudioStreamPlayer3D_finished():
	stream = Sounds.pop_front()
	Sounds.append(stream)
	if stream == first:
		_shuffle_start()
	else:
		play()
