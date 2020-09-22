class_name Worker

const types = [
	"WORK", 
	"FOOD",
	"ENTERTAINMENT",
	"PERSON",
	"OTHERS"
	]

signal workstation_assigned(where) 
signal stopped_working(type)

var working : bool = false
var current_station : Interactable = null
var experience : float = 0.0

func start_working(station : Interactable): 
	working = true
	current_station = station

func stop_working(type : int):
	working = false
	current_station = null
	emit_signal("stopped_working", types[type])

func _process_server(delta):
	if working:
		experience += current_station.do_work(1, experience)
