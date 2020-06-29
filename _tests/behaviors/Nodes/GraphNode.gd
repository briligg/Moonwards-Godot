tool
extends GraphNode
var func_name = "decide_fuzzy"
var content = [
	"trigger", 
	"desire1",
	"desire2",
	"desire3",
	"out1",
	"out2", 
	"out3"
	]
func _ready():
	for i in range(1,28):
		print(i, " Color : ", Nodes.color(i))
	set_slot(0, true, 28, Nodes.color(28), false,0, Color(0,1,0,1))
	set_slot(1, true, TYPE_REAL, Nodes.color(TYPE_REAL), true, 28, Nodes.color(28))
	set_slot(2, true, TYPE_REAL, Nodes.color(TYPE_REAL), true, 28, Nodes.color(28))
	set_slot(3, true, TYPE_REAL, Nodes.color(TYPE_REAL), true, 28, Nodes.color(28))
