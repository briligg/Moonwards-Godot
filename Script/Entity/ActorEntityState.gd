extends Reference
class_name ActorEntityState
# Bit flag
enum State {
	NONE = 0
	IDLE = 1
	MOVING = 2,
	IN_AIR = 4,
	INTERACTING = 8,
	}
	
var state: int = State.IDLE
var interactor: Node
