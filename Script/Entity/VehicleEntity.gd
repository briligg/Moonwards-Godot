extends AEntity
class_name VehicleEntity
# Entity class, serves as a medium between Components to communicate.

## Spatial Entity common data

onready var model = $Model

# `MASTER`
# Input vector
master var input: Vector3 = Vector3.ZERO

remote var look_dir: Vector3 = Vector3.FORWARD

# `PUPPET`
# The world position of this entity on the server
puppet var srv_pos: Vector3 = Vector3.ZERO

puppet var srv_basis: Basis = Basis.IDENTITY

# `PUPPET`
# Velocity in meters / second
puppet var velocity: float = 0.0

func _process_server(_delta: float) -> void:
	if !get_tree().network_peer:
		return
	rset_unreliable("srv_pos", srv_pos)
	rset_unreliable("srv_basis", srv_basis)
	rset_unreliable("velocity", velocity)
	
func _process_client(_delta: float) -> void:
	if !get_tree().network_peer:
		return
	# This needs to be validated on the server side.
	# Figure out a way to do that as godot doesn't have it out of the box
	# Setgetters are an option, try to find a cleaner way.
	if self.owner_peer_id == get_tree().get_network_unique_id():
		rset_unreliable_id(1, "input", input)
