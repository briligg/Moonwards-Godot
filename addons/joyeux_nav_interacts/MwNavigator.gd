extends WorldNavigator
enum {
	WORK, 
	FOOD,
	ENTERTAINMENT,
	OTHERS,
	ANY	
}
var Workstations : Array = []

func _ready():
	Workstations = get_tree().get_nodes_in_group("Workstations")
	
func get_nearest_workstation(position : Vector3, filter = ANY):
	var nearest : Spatial = Spatial.new()
	nearest.translation = position
	var nearest_size : int
	if Workstations.size()>0:
		for station in Workstations:
			if station.category == filter or filter == ANY:
				nearest = station
				nearest_size = get_navmesh_path(position, nearest.translation).size()
				break
	for station in Workstations:
		if station.category == filter or filter == ANY:
			if get_navmesh_path(position, station.translation).size() < nearest_size:
				nearest = station
				nearest_size = get_navmesh_path(position, station.translation).size()
	return nearest
