extends Reference
class_name LodSignals

### Until we or godot implements proper class_name handling
const name = "Lod"

const LOD_POS_CHANGED: String = "lod_pos_changed"

signal lod_pos_changed(pos)
