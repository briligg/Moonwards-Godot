extends AComponent
class_name Worker

signal workstation_assigned(where) 
signal stopped_working()

var working : bool = false
var current_station : Workstation = null
var experience : float = 0.0

func _init().("WorkController", false):
	pass

func start_working(station : Workstation): 
	working = true
	current_station = station

func stop_working():
	working = false
	current_station = null

func _process_server(delta):
	if working:
		experience += current_station.do_work(1, experience)
