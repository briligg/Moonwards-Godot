extends GraphNode
class_name BehaviorNode
signal connected_to(slot, type)
#emited when a node is connected to "slot", type is incoming type
signal disconnected_from(slot) 
#emited when a node has its slot disconnected
var slots_to_reset : Array = []

func _ready():
	connect("connected_to", self, "_on_connection_to")

func _on_connection_to(slot : int, type : int):
	if get_slot_type_left(slot) == Nodes.TYPE_ANY:
		for slots in get_child_count():
			if get_slot_type_right(slots):
				set_slot(slots, 
					is_slot_enabled_left(slots), 
					get_slot_type_left(slots),
					get_slot_color_left(slots),
					is_slot_enabled_right(slots), 
					type, 
					Nodes.Color(type))
				slots_to_reset.append(slots)

func  _on_disconnected_from(slot:int):
	for slots in slots_to_reset:
		set_slot(slots, 
					is_slot_enabled_left(slots), 
					get_slot_type_left(slots),
					get_slot_color_left(slots),
					is_slot_enabled_right(slots), 
					Nodes.TYPE_ANY, 
					Nodes.Color(Nodes.TYPE_ANY))
	pass
