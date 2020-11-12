extends Reference
class_name EntityData

var peer_id: int = -1
var entity_name: String = ""
var initial_pos: Vector3 = Vector3.ZERO
# Temporary until generic component instancing is available
var is_empty: bool = false

# Temporary until better player vs entity management is applied
var colors: Array = []

#Temporary until better player gender handling is implemented.
var gender : int = 0

func _init(_peer_id: int = -1, _entity_name: String = "", _initial_pos: Vector3 = Vector3.ZERO):
	self.peer_id = _peer_id
	self.entity_name = _entity_name
	self.initial_pos = _initial_pos

func serialize() -> Dictionary:
	return {"peer_id": peer_id,
			"entity_name": entity_name,
			"initial_pos": initial_pos,
			"is_empty": is_empty,
			"colors": colors,
			"gender": gender
			}

func deserialize(data: Dictionary): #-> PlayerData: - causes a memory leak for some reason.
	peer_id = int(data["peer_id"])
	entity_name = str(data["entity_name"])
	initial_pos = data["initial_pos"] as Vector3
	is_empty = bool(data["is_empty"])
	colors = data["colors"]
	gender = data["gender"]
	return self
