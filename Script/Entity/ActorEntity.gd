extends AEntity
# TODO: Decide whether a single type of entities will be enough.
# Should start showing when we add more things to the game.
class_name ActorEntity
# Entity class, serves as a medium between Components to communicate.

## Spatial Entity common data
# The current `state` of the entity. 
# Contains metadata in regards to what entity is currently doing.
var state: ActorEntityState = ActorEntityState.new()

# Velocity of the actor
export(Vector3) var velocity = Vector3()

# The angle at which we're looking relative to our transform
export(Vector3) var look_dir = Vector3()

# The `controller`'s transform
export(Transform) var ctrl_tform: Transform
