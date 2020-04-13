extends Node

var Entities = EntitySignals.new() setget _set_manager

# These are constant instances and should not be set at all.
func _set_manager(val):
	Log.warning(self, "_set_manager","Set invocation is illegal")
