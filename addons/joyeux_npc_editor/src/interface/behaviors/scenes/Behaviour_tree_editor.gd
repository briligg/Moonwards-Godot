tool
extends VSplitContainer

var type : String = ""
var node_name  : String = ""
var idx : int = 0
onready var Stimulus = $ViewMenuSplit/Container/Panel/DropDowns/stimulus.get_popup()
onready var Actions = $ViewMenuSplit/Container/Panel/DropDowns/actions.get_popup()
onready var Inhibitors = $ViewMenuSplit/Container/Panel/DropDowns/inhibitors.get_popup()
onready var Misc = $ViewMenuSplit/Container/Panel/DropDowns/misc.get_popup()

func _on_ready() -> void:
	Nodes.initiate()
	Stimulus.connect("index_pressed",self,"_on_Stimulus_selected")
	Actions.connect("index_pressed",self,"_on_Actions_selected")
	Inhibitors.connect("index_pressed",self, "_on_Inhibitions_selected")
	Misc.connect("index_pressed",self, "_on_Misc_selected")
	_generate_nodes()

func _on_Stimulus_selected(index) -> void:
	node_name = Stimulus.get_item_text(index)
	_update_labels("stimulus")
	
func _on_Actions_selected(index) -> void:
	node_name = Actions.get_item_text(index)
	_update_labels("actions")
	
func _on_Inhibitions_selected(index) -> void:
	node_name = Inhibitors.get_item_text(index)
	_update_labels("inhibitors")
	
func _on_Misc_selected(index) -> void:
	node_name = Misc.get_item_text(index)
	_update_labels("misc")
	
func _update_labels(name : String) -> void:
	type = name
	var Placeholder
	if Nodes.Graphs.get(name).get(node_name) is Node:
		Placeholder = Nodes.Graphs.get(name).get(node_name).duplicate(7)
	else:
		Placeholder = Nodes.Graphs.get(name).get(node_name).instance()
	$ViewMenuSplit/Container/selection/name.text = str(Placeholder.title)
	Placeholder.queue_free()

func _generate_nodes() -> void:
	for Any in Nodes.Graphs:
		var subdict = Nodes.Graphs.get(Any)
		get_node("ViewMenuSplit/Container/Panel/DropDowns/"+Any).get_popup().clear()
		get_node("ViewMenuSplit/GraphEdit/Behaviors/"+Any).clear()
		for N in subdict:
			get_node("ViewMenuSplit/Container/Panel/DropDowns/"+Any).get_popup().add_item(N)
			get_node("ViewMenuSplit/GraphEdit/Behaviors/"+Any).add_item(N)

func _on_Add_pressed() -> void:
	if (type == "" or node_name == ""):
		return
	var instanced = Nodes.Graphs.get(type).get(node_name)
	if instanced is Node:
		instanced = instanced.duplicate(7)
	else:
		instanced = instanced.instance()
	instanced.name = instanced.title 
	$ViewMenuSplit/GraphEdit.add_child(instanced)
	idx+=1
	

func _on_Open_pressed():
	$ViewMenuSplit/GraphEdit/Save.set_open()
	$ViewMenuSplit/GraphEdit/Save.popup_centered()
