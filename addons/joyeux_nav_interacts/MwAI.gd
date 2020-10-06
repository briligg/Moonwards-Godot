extends AComponent

"""
Interface to connect all signals to a behavior tree and provide its functionality
"""

export(String, FILE, "*.jsm") var NPC_File : String = "" #This works just fine! :D
export(String) var initial_state : String = ""
export(NodePath) var Interactable_Path : NodePath = ""


var BehaviorTree : MwNPC = null
var worker : Worker = Worker.new()

func _init().("AI handler", false):
	pass

func _ready():
	BehaviorTree = MwNPC.new(NPC_File, initial_state)
	BehaviorTree.actor = entity
	BehaviorTree.navigator = entity.get_component("NPCInput")
	BehaviorTree.worker = worker
	BehaviorTree._create_signal("workstation_assigned")
	BehaviorTree._create_signal("stopped_working")
	worker.connect("stopped_working", self, "_on_worker_stopped")
	worker.connect("workstation_assigned", self, "_on_worker_assigned")
	
	BehaviorTree._create_signal("interacted_by")
	get_node(Interactable_Path).connect("interacted_by", self, "_on_interacted")
	add_child(BehaviorTree)
	BehaviorTree.load_colors()
	
func _on_interacted(anything):
	BehaviorTree.emit_signal("interacted_by", anything)

func _on_worker_stopped():
	BehaviorTree.emit_signal("stopped_working")

func _on_worker_asssigned(where):
	BehaviorTree.emit_signal("workstation_assigned", where)
