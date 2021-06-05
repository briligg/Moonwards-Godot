extends EPIBase
class_name SwitchContextEPI

#Make a don't actually change variable for dummy scripts.
export(bool) var is_dummy : bool = false

signal context_lost()
const CONTEXT_LOST = "context_lost"
signal context_taken()
const CONTEXT_TAKEN = "context_taken"

func take_context_from(old_context : SwitchContextEPI = null) -> void :
	if old_context == null || is_dummy :
		return
	
	old_context.emit_signal(old_context.CONTEXT_LOST)
	emit_signal(CONTEXT_TAKEN)
