extends Spatial
class_name LodModel

var _lods = {}
var lod_enabled: bool = false

func _ready():
	_lods[0] = get_child(0)
	_lods[1] = get_child(1)
	_lods[2] = get_child(2)
	lod_enabled = true
	add_to_group(Groups.LOD_MODELS)
##
#func _ready():
#	for i in range(0,3):
#		var l = get_child(i)
#		if l != null:
#			_lods[i] = l
#	if _lods.size() == 3:
#		lod_enabled = true
#	add_to_group(Groups.LOD_MODELS)

func set_lod(level: int)-> void:
	if !lod_enabled:
		return
	hide_all()
	_lods[level].visible = true;

func hide_all()-> void:
	if !lod_enabled:
		return
	for i in range(_lods.size()):
		_lods[i].visible = false;
