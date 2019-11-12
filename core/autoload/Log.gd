extends Reference
class_name Log
"""
	Log Utility Class Script
"""
enum LEVEL {HINT, WARNING, ERROR}
const LOG_LEVEL: int = LEVEL.ERROR


static func hint(emitter: Object, message: String) -> void:
	_log(emitter, message, LEVEL.HINT)


static func warning(emitter: Object, message: String) -> void:
	_log(emitter, message, LEVEL.WARNING)


static func error(emitter: Object, message: String) -> void:
	_log(emitter, message, LEVEL.ERROR)


static func _log(emitter: Object, message: String, level: int) -> void:
	var script = emitter.get_script().get_path().get_file()
	
	if LOG_LEVEL >= level:
	
		match level:
			
			LEVEL.HINT:
				print("_HINT: %s: %s : %s" % [emitter, script, message])
		
			LEVEL.WARNING:
				print("_WARNING: %s: %s : %s" % [emitter, script, message])
		
			LEVEL.ERROR:
				print("_ERROR: %s: %s : %s" % [emitter, script, message])
				assert(false)