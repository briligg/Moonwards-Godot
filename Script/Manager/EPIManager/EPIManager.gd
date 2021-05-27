extends Node


func get_dummy_epi(epi_name : String) -> EPIBase :
	assert(has_node(epi_name))
	var epi : EPIBase = get_node(epi_name)
	return epi
