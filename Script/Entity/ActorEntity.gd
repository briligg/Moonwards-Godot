extends AEntity
class_name ActorEntity
# Entity class, serves as a medium between Components to communicate.

signal on_forces_integrated(state)

## Spatial Entity common data

onready var model = $Model
onready var animation = $Model/AnimationPlayer
onready var animation_tree = $Model/AnimationTree
var stairs = null
var climb_point = -1
var climb_points : Array = []
var climb_look_direction = Vector3.FORWARD

# The current `state` of the entity. 
# Contains metadata in regards to what entity is currently doing.
var state: ActorEntityState = ActorEntityState.new()

# `MASTER`
# Input vector
master var input: Vector3 = Vector3.ZERO
# So clients are able to update their look direction without modifying
# the original variable (Godot's mad about it even when marked as `remote`, makes sense tho)
master var mlook_dir setget set_mlook_dir

# `REMOTE`
# Look dir of our actor
puppet var look_dir: Vector3 = Vector3.FORWARD
var prev_look_dir : Vector3 = Vector3.FORWARD

# `PUPPET`
# The world position of this entity on the server
puppet var srv_pos: Vector3 = Vector3.ZERO
var prev_srv_pos : Vector3 = Vector3.ZERO
const DISTANCE_SRV_POS = 0.05 #How far the prev pos must be from srv_pos before  networking.
#puppet var srv_vel: Vector3 = Vector3.ZERO

# Velocity of the actor
var velocity = Vector3()

var is_grounded: bool

func _integrate_server(_args) -> void:
	if !get_tree().network_peer:
		return
#	Network.crset_unreliable(self, "srv_pos", srv_pos, [1])
#	Network.crset_unreliable(self, "look_dir", look_dir, [1])
	if srv_pos.distance_to(prev_srv_pos) > DISTANCE_SRV_POS :
		rset_unreliable("srv_pos", srv_pos)
		prev_srv_pos = srv_pos
	if prev_look_dir != look_dir :
		rset_unreliable("look_dir", look_dir)
		prev_look_dir = look_dir
#	rset_unreliable("srv_vel", srv_vel)
	
func _integrate_client(_args) -> void:
	if !get_tree().network_peer:
		return
	# This needs to be validated on the server side.
	# Figure out a way to do that as godot doesn't have it out of the box
	# Setgetters are an option, try to find a cleaner way.
	if self.owner_peer_id == get_tree().get_network_unique_id():
		rset_id(1, "input", input)
		rset_id(1, "mlook_dir", look_dir)

func _integrate_forces(new_state):
	emit_signal("on_forces_integrated", new_state)
	invoke_network_based("_integrate_server", "_integrate_client", [new_state])

func invoke_network_based(server_func: String, client_func: String, args):
	if !get_tree().network_peer:
		return
	if get_tree().is_network_server() and self.owner_peer_id == get_tree().get_network_unique_id():
		call(server_func, args)
		call(client_func, args)
	elif get_tree().is_network_server():
		call(server_func, args)
	else:
		call(client_func, args)

func set_mlook_dir(val):
	look_dir = val
