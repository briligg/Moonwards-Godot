extends Node

# Max distance to show LOD level at.
export(float) var lod0_distance: float = 0
export(float) var lod1_distance: float = 0
export(float) var lod2_distance: float = 0
export(float) var cull_distance: float = 0

# The amount of frames over which to split the LOD updates
var lod_frames: int = 5

# The position of the entity based on which LOD is applied
var lodder_pos: Vector3 = Vector3.ZERO

var pos_updated = false

func _ready():
	Signals.Lod.connect(Signals.Lod.LOD_POS_CHANGED, 
		self, "_lod_pos_changed")
	pass

# Could be optimized
func _physics_process(_delta):
	if pos_updated == true:
		var lods = get_tree().get_nodes_in_group(Groups.LOD_MODELS)
		for lod in lods:
			process_lod(lod)
	pos_updated = false

func process_lod(lod: LodModel)-> void:
	var dist = (lodder_pos - lod.global_transform.origin).length()
	if dist < lod0_distance:
		lod.set_lod(0)
	elif dist > lod0_distance and dist < lod1_distance:
		lod.set_lod(1)
	elif dist > lod1_distance and dist < lod2_distance:
		lod.set_lod(2)
	elif dist > cull_distance:
		lod.hide_all()

func _lod_pos_changed(pos: Vector3)-> void:
	lodder_pos = pos
	pos_updated = true
