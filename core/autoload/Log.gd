extends Control
#class_name Log
"""
	Log Utility Class Script
"""
enum LEVEL {HINT, WARNING, ERROR}
const LOG_LEVEL: int = LEVEL.ERROR

var log_ui_resource = preload("res://assets/UI/Log/LogUI.tscn")
var log_ui : Node = null
const log_data : Array = []

static func hint(emitter: Object, message: String) -> void:
	_log(emitter, message, LEVEL.HINT)


static func warning(emitter: Object, message: String) -> void:
	_log(emitter, message, LEVEL.WARNING)


static func error(emitter: Object, message: String) -> void:
	_log(emitter, message, LEVEL.ERROR)


static func _log(emitter: Object, message: String, level: int) -> void:
	var script = emitter.get_script().get_path().get_file()
	var log_message
	
	if LOG_LEVEL >= level:
	
		match level:
			
			LEVEL.HINT:
				log_message = "%-10s: %-15s: %-20s: %-10s" % ["_HINT", emitter, script, message]
				print(log_message)
		
			LEVEL.WARNING:
				log_message = "%-10s: %-15s: %-20s: %-10s" % ["_WARNING", emitter, script, message]
				print(log_message)
		
			LEVEL.ERROR:
				log_message = "%-10s: %-15s: %-20s: %-10s" % ["_ERROR", emitter, script, message]
				assert(false)
		
		log_data.append({"level" : level, "log_message" : log_message})
		if Log.log_ui != null:
			Log.log_ui.add_message(log_data.back())

func _input(var event : InputEvent):
	if event.is_action_pressed("toggle_log"):
		if log_ui == null:
			log_ui = log_ui_resource.instance()
			get_tree().root.add_child(log_ui)
		else:
			log_ui.queue_free()
			log_ui = null