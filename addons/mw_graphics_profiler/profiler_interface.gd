tool
extends ScrollContainer
var items : Array = []

onready var paths = $HSplitContainer/Paths 
onready var data = $HSplitContainer/Data

func add_data(path, obj_number, vertex, total_vertex, drawcalls) -> Dictionary:
	var dict : Dictionary = {}
	dict["route"] = LineEdit.new()
	dict["route"].editable = false
	dict["route"].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dict["container"] = HBoxContainer.new()
	dict["objects"] = Label.new()
	dict["objects"].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dict["vertex_total"] = Label.new()
	dict["vertex_total"].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dict["vertex"] = Label.new()
	dict["vertex"].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dict["draw_calls"] = Label.new()
	dict["draw_calls"].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	dict["route"].text = path
	dict["objects"].text = obj_number
	dict["vertex"].text = vertex
	dict["vertex_total"].text = total_vertex
	dict["draw_calls"].text = drawcalls
	
	
	dict["container"].add_child(dict["objects"])
	dict["container"].add_child(dict["vertex"])
	dict["container"].add_child(dict["vertex_total"])
	dict["container"].add_child(dict["draw_calls"])
	
	
	paths.add_child(dict["route"])
	data.add_child(dict["container"])
	
	items.append(dict)
	
	return {
		"id" : items.size()-1,
		"dict" : dict
	}

func set_data(dict, path, obj_number, vertex, total_vertex, drawcalls):
	dict["route"].text = path
	dict["objects"].text = obj_number
	dict["vertex"].text = vertex
	dict["vertex_total"].text = total_vertex
	dict["draw_calls"].text = drawcalls

func set_data_on_id(id, path, obj_number, vertex, total_vertex, drawcalls):
	items[id]["route"].text = path
	items[id]["objects"].text = obj_number
	items[id]["vertex"].text = vertex
	items[id]["vertex_total"].text = total_vertex
	items[id]["draw_calls"].text = drawcalls
	

func delete_dict(dict : Dictionary):
	dict["container"].queue_free()
	dict["route"].queue_free()
	
	items.erase(dict)
	pass
func delete_item(id : int):
	items[id]["route"].queue_free()
	items[id]["container"].queue_free()
	items.remove(id)
