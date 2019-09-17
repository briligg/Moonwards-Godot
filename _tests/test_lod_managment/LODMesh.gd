extends Spatial

export(int) var step = 3
export(int) var count = 100

func propagate():
	yield(get_tree(), "idle_frame")
	var btscn = ResourceLoader.load(filename)
	var origin = translation
	var x = floor(sqrt(count))
	var root = get_tree().current_scene
	for i in range(-x, x):
		for j in range(-x, x):
			if i == 0 and j == 0:
				continue
			var obj = btscn.instance()
			obj.translation = Vector3(i*step, 0, j*step) + origin
			print("node: %s %s" % [i, j])
			root.add_child(obj)

func _ready():
	propagate()
