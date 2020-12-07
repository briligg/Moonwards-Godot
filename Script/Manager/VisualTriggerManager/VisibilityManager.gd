extends Node

enum LodState {
	LOD0 = 0,
	LOD1 = 1,
	LOD2 = 2,
	HIDDEN = 255,
}

signal queue_requested(fref)

####
# For debugging purposes
export(bool) var disable_all_triggers = false

export(bool) var disable_default_lod = false

export(bool) var log_lod_changes = false

export(bool) var log_vt_changes = false
####

# The maximum  amount of LOD changes to be performed every frame
export(int) var iterations_per_frame  = 8

export(LodState) var default_lod_state = LodState.LOD0

var worker_thread: ThreadWorker

# LOD Context, a list of active LOD nodes and their previous lod states
# States are cached upon switching context (ex: mounting a rover)
var current_lod_context = { }

var lod_contexts: Array = []

# Whether or not we're on the default context.
var context_step: int = -1

func _ready():
	worker_thread = ThreadWorker.new()
	self.add_child(worker_thread)
	connect("queue_requested", self, "queue_thread_work")
	
# Register a lod model to context 
func update_context(node):
	if node is LodModel:
		current_lod_context[node] = node.lod_state
	else:
		current_lod_context[node] = node.visible

func queue_thread_work(fref: FuncRef):
	worker_thread.queue_thread_work(fref)

func switch_context():
	worker_thread.queue_thread_work(funcref(self, "_switch_context"))

func reverse_context():
	worker_thread.queue_thread_work(funcref(self, "_switch_context"))

# Adds a new context & switches to it, keeping the older context in the cache
func _switch_context():
	lod_contexts.append(current_lod_context.duplicate())
	current_lod_context.clear()
	context_step += 1

# Reverses to the previous context, discarding the most recent one being switched from.
func _reverse_context():
	current_lod_context = lod_contexts[context_step]
	lod_contexts.remove(context_step)
	context_step -= 1
	_apply_context(current_lod_context)

func _apply_context(context):
	for node in context.keys():
		node.call_deferred("set_lod", context[node])
	
func _exit_tree():
	worker_thread._exit_tree()
