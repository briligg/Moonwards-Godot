extends EPIBase
class_name SwitchContextEPI

#Make a variable for when we are a dummy EPI.
export(bool) var is_dummy : bool = false

signal context_data_given(player_name_string)
const CONTEXT_DATA_GIVEN = "context_data_given"
signal context_lost()
const CONTEXT_LOST = "context_lost"
signal context_taken()
const CONTEXT_TAKEN = "context_taken"

var previous_context : SwitchContextEPI = null

puppetsync func give_context_through_network(player_name : String) -> void :
	emit_signal(CONTEXT_DATA_GIVEN, player_name)

#Take context from whatever had context before it.
func take_context_from(old_context : SwitchContextEPI = null, player_name : String = "") -> void :
	#Do nothing if we are a dummy EPI.
	if is_dummy :
		return
	
	else : 
		if old_context != null && not old_context.is_dummy :
			previous_context = old_context
			old_context.emit_signal(old_context.CONTEXT_LOST)
		emit_signal(CONTEXT_TAKEN)
		
		rpc("give_context_through_network", player_name)
