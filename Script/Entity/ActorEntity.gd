extends AEntity
# TODO: Decide whether a single type of entities will be enough.
# Should start showing when we add more things to the game.
class_name ActorEntity
# Entity class, serves as a medium between Components to communicate.

var state: ActorEntityState = ActorEntityState.new()

# Spatial Entity common data
export(Vector3) var velocity: Vector3 = Vector3.ZERO
# The controller's transform
export(Transform) var ctrl_tform: Transform

export(Vector3) var look_dir: Vector3 = Vector3.ZERO
