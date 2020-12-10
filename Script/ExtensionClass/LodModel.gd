extends Spatial
class_name LodModel

var _lods = {}
var lod_enabled: bool = false

var lod_state setget _set_illegal

func _ready() -> void:
	_ready_lod()

func _ready_lod():
	if self.has_node("LOD0") and self.has_node("LOD1") and self.has_node("LOD2"):
		_lods[0] = $LOD0
		_lods[1] = $LOD1
		_lods[2] = $LOD2
		lod_enabled = true
		add_to_group(Groups.LOD_MODELS)
		if !VisibilityManager.disable_default_lod:
			set_lod(VisibilityManager.default_lod_state)
	else:
		lod_enabled = false

func set_lod(level: int)-> void:
	if !lod_enabled:
		return
		
	hide_all()
	if level != VisibilityManager.LodState.HIDDEN:
		if _lods[level] != null:
			_lods[level].visible = true;
		
	lod_state = level
	if VisibilityManager.log_lod_changes:
		Log.trace(self, "", "Lod changed to %s for object %s" %[level, self.name])
	VisibilityManager.update_context(self)

func hide_all()-> void:
	if !lod_enabled:
		return
	for i in range(_lods.size()):
		if _lods[i] == null:
			Log.error(self, "hide_all", "LODx nodes do not exist for object: %s." %self.get_path())
		else:
			_lods[i].visible = false;
	lod_state = VisibilityManager.LodState.HIDDEN

# Generate collision shapes for distance based LOD - currently legacy code.
#func _generate_col_shape():
#	var col = CollisionShape.new()
#	var shape = SphereShape.new()
#	shape.radius = 0.1
#	shape.margin = 0.1
#	col.shape = shape
#	self.add_child(col)

func _set_illegal(_val) -> void:
	Log.warning(self, "", "Set is illegal.")
