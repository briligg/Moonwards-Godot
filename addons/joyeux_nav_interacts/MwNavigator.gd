extends WorldNavigator

var Workstations : Array = []

func _ready():
	Workstations = get_tree().get_nodes_in_group("Workstations")
	
func get_nearest_workstation(position : Vector3):
	var nearest
	if Workstations.size()>0:
		nearest = Workstations[0]
	for station in Workstations:
		if (station.translation - position).length() < (nearest.translation - position).length():
			nearest = station
	return nearest
