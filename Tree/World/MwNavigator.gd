extends WorldNavigator
class_name MwNavigator
enum {
	WORK, 
	FOOD,
	ENTERTAINMENT,
	PERSON,
	OTHERS,
	ANY	
}
var Workstations : Array = []

func _ready():
	Workstations = get_tree().get_nodes_in_group("Workstations")
	
func get_nearest_workstation(position : Vector3, filter : int = ANY):
	var nearest : Spatial = Spatial.new()
	nearest.translation = position
	var nearest_size : int
	if Workstations.size()>0:
		for station in Workstations:
			if station.category == filter or filter == ANY:
				nearest = station
				nearest_size = get_navmesh_path(position, nearest.position).size()
				break
	for station in Workstations:
		if station.category == filter or filter == ANY:
			if get_navmesh_path(position, station.position).size() < nearest_size:
				if get_navmesh_path(position, station.position).size() > 0:
					nearest = station
					nearest_size = get_navmesh_path(position, station.position).size()
	return nearest

func request_workstation(worker : Worker, filter : int = ANY):
	for station in Workstations:
		if station.category == filter or filter == ANY:
			if station.request_workstation(worker):
				print("looking for ", filter)
				return
	worker.emit_signal("request_rejected")
