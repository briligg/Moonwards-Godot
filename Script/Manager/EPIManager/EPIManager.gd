extends Node

const INPUT_EPI : String = "InputEPI"

const SWITCH_CONTEXT_EPI = "SwitchContextEPI"

const HUMANOID_ENTITY_EPI = "HumanoidEntityEPI"


func get_dummy_epi(epi_name : String) -> EPIBase :
	assert(has_node(epi_name))
	var epi : EPIBase = get_node(epi_name)
	return epi
