extends AEntity
# TODO: Decide whether a single type of entities will be enough.
# Should start showing when we add more things to the game.
class_name ActorEntity
# Entity class, serves as a medium between Components to communicate.

## Spatial Entity common data

onready var model = $Model
onready var animation = $Model/AnimationPlayer
onready var animation_tree = $Model/AnimationTree
onready var im = $Model/ImmediateGeometry

# The current `state` of the entity. 
# Contains metadata in regards to what entity is currently doing.
var state: ActorEntityState = ActorEntityState.new()

# `MASTER`
# Input vector
master var input: Vector3 = Vector3.ZERO

# `REMOTE`
# Look dir of our actor
remote var look_dir: Vector3 = Vector3.FORWARD

# `PUPPET`
# The world position of this entity on the server
puppet var srv_pos: Vector3 = Vector3.ZERO

# Velocity of the actor
var velocity = Vector3()

var is_grounded: bool

func _process_server(_delta) -> void:
	rset_unreliable("srv_pos", srv_pos)
	rset_unreliable("look_dir", look_dir)

func _process_client(_delta) -> void:
	
	# This needs to be validated on the server side.
	# Figure out a way to do that as godot doesn't have it out of the box
	# Setgetters are an option, try to find a cleaner way.
	if self.owner_peer_id == get_tree().get_network_unique_id():
		rset_unreliable_id(1, "input", input)
		rset_unreliable_id(1, "look_dir", look_dir)
