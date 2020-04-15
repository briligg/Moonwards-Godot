extends AEntity
# TODO: Decide whether a single type of entities will be enough.
# Should start showing when we add more things to the game.
class_name ActorEntity
# Entity class, serves as a medium between Components to communicate.

signal velocity_changed(val)
signal look_dir_changed(val)
signal look_rot_changed(val)

var state: ActorEntityState = ActorEntityState.new()

# Spatial Entity common data
export(Vector3) var velocity: Vector3 = Vector3.ZERO
export(Vector3) var look_dir: Vector3 = Vector3.ZERO
export(Vector3) var look_rot: Vector3 = Vector3.ZERO
