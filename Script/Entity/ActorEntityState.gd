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
var interactor_id: int = -1


func serialize() -> Dictionary:
	return {
		"state": state,
		"interactor_id": interactor_id,
	}
	
func deserialize(data: Dictionary) -> ActorEntityState:
	self.state = data.state
	self.interactor_id = data.interactor_id
	return self
