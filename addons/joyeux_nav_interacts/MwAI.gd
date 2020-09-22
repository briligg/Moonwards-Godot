extends AComponent

export(String, FILE, "*.jsm") var NPC_File : String = "" #This works just fine! :D
export(String) var initial_state : String = ""
export(NodePath) var NPC_input_path : NodePath = ""


var BehaviorTree : MwNPC = null
var worker : Worker = Worker.new()

func _init().("AI handler", false):
	pass

func _ready():
	BehaviorTree = MwNPC.new(NPC_File, initial_state)
	BehaviorTree.naviagtor = get_node(NPC_input_path)
	BehaviorTree.worker = worker
	
