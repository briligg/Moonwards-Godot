tool
extends GraphNode
class_name BehaviorNode
signal connected_to(slot, type)
#emited when a node is connected to "slot", type is incoming type
signal disconnected_from(slot) 
#emited when a node has its slot disconnected
var slots_to_reset : Array = []

func _ready():
	connect("connected_to", self, "_on_connection_to")
	connect("disconnected_from", self, "_on_disconnected_from")
	for id in get_children().size():
		var child = get_child(id)
		for subchild in child.get_children():
			if subchild is DropDown:
				subchild.connect("selected_type", self, "_on_dropdown_change", [id])
				
func _on_connection_to(slot : int, type):
	if get_slot_type_left(slot) == Nodes.TYPE_ANY:
		for slots in get_child_count():
			if get_slot_type_right(slots) == Nodes.TYPE_ANY:
				set_slot(slots, 
					is_slot_enabled_left(slots), 
					get_slot_type_left(slots),
					get_slot_color_left(slots),
					is_slot_enabled_right(slots), 
					Nodes._get_type(type), 
					Nodes.Color(type))
				slots_to_reset.append(slots)

func  _on_disconnected_from(_slot:int):
	for slots in slots_to_reset:
		set_slot(slots, 
					is_slot_enabled_left(slots), 
					get_slot_type_left(slots),
					get_slot_color_left(slots),
					is_slot_enabled_right(slots), 
					Nodes.TYPE_ANY, 
					Nodes.Color(Nodes.TYPE_ANY))

func _on_dropdown_change(type, slot):
	print(type)
	for slots in get_child_count():
					set_slot(slots, 
					is_slot_enabled_left(slots), 
					get_slot_type_left(slots),
					get_slot_color_left(slots),
					is_slot_enabled_right(slots), 
					Nodes._get_type(type), 
					Nodes.Color(type))
