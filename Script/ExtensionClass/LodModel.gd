extends Spatial
class_name LodModel

var _lods = {}
var lod_enabled: bool = false
export(bool) var debug_lod = false

func _ready():
	if self.has_node("LOD0") and self.has_node("LOD1") and self.has_node("LOD2"):
		_lods[0] = $LOD0
		_lods[1] = $LOD1
		_lods[2] = $LOD2
		lod_enabled = true
		add_to_group(Groups.LOD_MODELS)
	else:
		lod_enabled = false		

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
	if debug_lod:
		Log.trace(self, "", "Lod changed to %s for object %s" %[level, self])

func hide_all()-> void:
	if !lod_enabled:
		return
	for i in range(_lods.size()):
		_lods[i].visible = false;
