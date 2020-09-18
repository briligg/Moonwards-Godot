extends Interactable
class_name Workstation
"""
Base class  for the NPC Interactors, namely Workstations. 
This class contains methods that must be overriden. 
"""
enum CATEGORY {
	WORK, 
	FOOD,
	ENTERTAINMENT,
	OTHERS
}

var progress : float = 0.0
var in_queue_for_use : Array = []
var current_worker : Worker = null
var orientation : Vector3 = Vector3.ZERO
var position : Vector3 = Vector3.ZERO

export(bool) var uses_queue : bool = false
export(bool) var call_best_first : bool = false
export(bool) var gives_xp : bool = false
export(CATEGORY) var category : int = CATEGORY.WORK

func _enter_tree():
	add_to_group("Workstations")
	connect("body_entered", self, "_on_body_entered")

func _ready():
	var pos = get_node("NPCPosition")
	if pos:
		orientation = pos.rotation_degrees
		position = pos.translation

func check_for_next():
	if not uses_queue:
		return
	if call_best_first:
		assign(select_best_from_queue())
	else:
		assign(select_neareast())
	
func do_work(amount: float, experience : float) -> float:
	progress += (amount * experience)/100
	if progress >= 100:
		is_available = true
		current_worker.stop_working()
		check_for_next()
	if gives_xp:
		return amount/100
	return 0.0

func select_best_from_queue():
	var best_worker : Worker = null
	if in_queue_for_use.size() < 1:
		return
	best_worker = in_queue_for_use[0]
	for worker in in_queue_for_use:
		if worker.experience > best_worker.experience:
			best_worker = worker
	return best_worker
	
func select_neareast():
	var nearest_worker : Worker = null
	if in_queue_for_use.size() < 1:
		return
	nearest_worker = in_queue_for_use[0]
	for worker in in_queue_for_use:
		if (worker.entity.translation - translation).length() < (nearest_worker.entity.translation - translation).length():
			nearest_worker = worker
	return nearest_worker

func assign(worker : Worker):
	if worker == null:
		return
	is_available = false
	current_worker = worker
	worker.emit_signal("workstation_assigned", translation)

func request_workstation(worker : Worker):
	if uses_queue:
		in_queue_for_use.append(worker)
	elif is_available:
		is_available = false
		assign(worker)
	else:
		return

func _on_body_entered(body):
	var worker : Worker = body.get_node("Worker")
	if worker:
		if worker == current_worker:
			worker.start_working(self)
			_change_state_on_user(worker)
			
func _change_state_on_user(worker : Worker):
	#This is meant for changing animation states, so it changes depending on the 
	#type of workstation
	pass
