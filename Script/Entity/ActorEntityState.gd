extends Reference
class_name ActorEntityState

# Bit flag
enum State {
	NONE = 0
	IDLE = 1
	MOVING = 2,
	IN_AIR = 4,
	INTERACTING = 8,
	CLIMBING = 16,
	FLY = 32
	}

var state: int = State.IDLE setget set_state
var changed = false setget , get_changed
var interactor_id: int = -1


func serialize() -> Dictionary:
	return {
		"state": state,
		"interactor_id": interactor_id,
	}
	
func deserialize(data: Dictionary):
	self.state = data.state
	self.interactor_id = data.interactor_id
	return self

func set_state(val):
	if val != state:
		changed = true
		
	state = val

func get_changed():
	if changed:
		changed = false
		return true
	else:
		return false
