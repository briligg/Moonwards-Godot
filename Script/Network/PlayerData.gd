extends Reference
class_name PlayerData

var peer_id: int = -1
var name: String = ""
var initial_pos: Vector3 = Vector3.ZERO

func _init(_peer_id: int = -1, _name: String = "", _initial_pos: Vector3 = Vector3.ZERO):
	self.peer_id = _peer_id
	self.name = _name
	self.initial_pos = _initial_pos

func serialize() -> Dictionary:
	return {"peer_id": peer_id,
			"name": name,
			"initial_pos": initial_pos,
			}

func deserialize(data: Dictionary): #-> PlayerData: - causes a memory leak for some reason.
	peer_id = int(data["peer_id"])
	name = str(data["name"])
	initial_pos = data["initial_pos"] as Vector3
	return self
