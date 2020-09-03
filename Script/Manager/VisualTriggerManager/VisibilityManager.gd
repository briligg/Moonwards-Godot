extends Node

enum LodState {
	LOD0 = 0,
	LOD1 = 1,
	LOD2 = 2,
	HIDDEN = 255,
}

####
# For debugging purposes
export(bool) var disable_all_triggers = false

export(bool) var log_lod_changes = false

export(bool) var log_vt_changes = false
####

export(LodState) var default_lod_state = LodState.LOD0

# LOD Context, a list of active LOD nodes and their previous lod states
# States are cached upon switching context (ex: mounting a rover)
var current_lod_context = { }

var lod_contexts: Array = []

# Whether or not we're on the default context.
var context_step: int = -1

# Register a lod model to context 
func update_context(node: LodModel):
	current_lod_context[node] = node.lod_state

# Adds a new context & switches to it, keeping the older context in the cache
func switch_context():
	lod_contexts.append(current_lod_context.duplicate())
	current_lod_context.clear()
	context_step += 1

# Reverses to the previous context, discarding the most recent one being switched from.
func reverse_context():
	current_lod_context = lod_contexts[context_step]
	lod_contexts.remove(context_step)
	context_step -= 1
	_apply_context(current_lod_context)

func _apply_context(context):
	for node in context.keys():
		node.set_lod(context[node])
	
