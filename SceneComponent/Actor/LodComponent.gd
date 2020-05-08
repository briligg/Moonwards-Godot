extends AComponent

var last_pos: Vector3 = Vector3.ZERO

func _init().("LodComponent", true):
	pass

func _ready():
	pass 

func _physics_process(delta):
	var pos = entity.global_transform.origin
	if pos != last_pos:
		last_pos = pos
		Signals.Lod.emit_signal(Signals.Lod.LOD_POS_CHANGED, pos)
