extends AEntity
class_name StaticEntity

# Syncs server state if set to true
var is_syncing = false

## Spatial Entity common data
onready var model = $Model
onready var animation = $Model/AnimationPlayer

# `PUPPET`
# The world position of this entity on the server
puppet var srv_pos: Vector3 = Vector3.ZERO

func _process_server(_delta: float) -> void:
	if !get_tree().network_peer:
		return
	if is_syncing:
		rset_unreliable("srv_pos", srv_pos)

func _process_client(_delta: float) -> void:
	return
