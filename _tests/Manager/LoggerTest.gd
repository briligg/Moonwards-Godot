extends Node


func _ready():
	Log.trace(self, "_ready", "trace test")
	Log.debug(self, "_ready", "debug test")
	Log.warning(self, "_ready", "warning test")
	Log.error(self, "_ready", "error test")
	Log.critical(self, "_ready", "critical test")
