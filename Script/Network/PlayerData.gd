extends Reference
class_name PlayerData

var peer_id: int = -1
var name: String = ""
var initial_pos: Vector3 = Vector3.ZERO
# Temporary until generic component instancing is available
var is_empty: bool = false

func _init(_peer_id: int = -1, _name: String = "", _initial_pos: Vector3 = Vector3.ZERO):
	self.peer_id = _peer_id
	self.name = _name
	self.initial_pos = _initial_pos

func serialize() -> Dictionary:
	return {"peer_id": peer_id,
			"name": name,
			"initial_pos": initial_pos,
			"is_empty": is_empty,
			}

func deserialize(data: Dictionary): #-> PlayerData: - causes a memory leak for some reason.
	peer_id = int(data["peer_id"])
	name = str(data["name"])
	initial_pos = data["initial_pos"] as Vector3
	is_empty = bool(data["is_empty"])
	return self
