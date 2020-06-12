extends Node
"""
	Logger Singleton Class Script
	Provides functions for logging of various levels of message to disk.
	The `F3` button (or any key assigned to `toggle_logger` action) opens up
		in-game console logger.
	
	Usage example:
	
	trace(self, "function_name", "thing went wrong")
	
	Description:
		
	The log does have 5 levels:
	TRACE: Informational messages that are used to depict application state
		status/progress & program flow.
	DEBUG: These messages will be more granular, detailed & include useful info
		to debug the application.
	WARNING: Messages to hint that an issue might be happening, but not
		necessarily. Issues that WARN do not necessarily affect the flow of
		the application.
	ERROR: Messages to hint that an issue probably affects the program flow,
		but not necessarily. Regardless, ERRORs are messages that require
		attention & need to be fixed.
	CRITICAL: Things that definitely break the program flow, and require
		immediate attention. The program can not progerss past this type of error. 
"""
const ERRORS = [
"OK", "FAILED", "ERR_UNAVAILABLE", "ERR_UNCONFIGURED", "ERR_UNAUTHORIZED",
"ERR_PARAMETER_RANGE_ERROR", "ERR_OUT_OF_MEMORY", "ERR_FILE_NOT_FOUND", "ERR_FILE_BAD_DRIVE",
"ERR_FILE_BAD_PATH", "ERR_FILE_NO_PERMISSION", "ERR_FILE_ALREADY_IN_USE", "ERR_FILE_CANT_OPEN",
"ERR_FILE_CANT_WRITE", "ERR_FILE_CANT_READ", "ERR_FILE_UNRECOGNIZED","ERR_FILE_CORRUPT",
"ERR_FILE_MISSING_DEPENDENCIES", "ERR_FILE_EOF", "ERR_CANT_OPEN", "ERR_CANT_CREATE",
"ERR_QUERY_FAILED", "ERR_ALREADY_IN_USE", "ERR_LOCKED", "ERR_TIMEOUT",
"ERR_CANT_CONNECT", "ERR_CANT_RESOLVE", "ERR_CONNECTION_ERROR", "ERR_CANT_ACQUIRE_RESOURCE",
"ERR_CANT_FORK", "ERR_INVALID_DATA", "ERR_INVALID_PARAMETER", "ERR_ALREADY_EXISTS",
"ERR_DOES_NOT_EXIST", "ERR_DATABASE_CANT_READ", "ERR_DATABASE_CANT_WRITE",
"ERR_COMPILATION_FAILED", "ERR_METHOD_NOT_FOUND", "ERR_LINK_FAILED", "ERR_SCRIPT_FAILED",
"ERR_CYCLIC_LINK", "ERR_INVALID_DECLARATION", "ERR_DUPLICATE_SYMBOL", "ERR_PARSE_ERROR",
"ERR_BUSY", "ERR_SKIP", "ERR_HELP", "ERR_BUG", "ERR_PRINTER_ON_FIRE" ] 

signal trace_logged(message)
signal debug_logged(message)
signal warning_logged(message)
signal error_logged(message)
signal critical_logged(message)

enum LEVELS {TRACE, DEBUG, WARNING, ERROR, CRITICAL}

# Configuration Variables.
var log_level: int = LEVELS.TRACE # Lowest level that should be logged
var enabled: bool = true # Log anything at all?
var use_builtin_console: bool = true # Will instance a rich text label to log to
var console_canvas_layer: int = 10 # What canvas layer to place the label on


func _ready() -> void:
	if use_builtin_console:
		pass


func error_to_string(code : int) -> String:
	return ERRORS[code]


func trace(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.TRACE:
		_log_message(LEVELS.TRACE, emitter, function, message)


func debug(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.DEBUG:
		_log_message(LEVELS.DEBUG, emitter, function, message)


func warning(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.WARNING:
		_log_message(LEVELS.WARNING, emitter, function, message)


func error(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.ERROR:
		_log_message(LEVELS.ERROR, emitter, function, message)


func critical(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.CRITICAL:
		_log_message(LEVELS.CRITICAL, emitter, function, message)


func _log_message(level: int, emitter: Object, function: String, message: String) -> void:
	var log_string: String = ""
	var is_print: bool = true
	var is_stack_print: bool = false
	
	log_string += "[" + _get_time_string() + "]"
	log_string += " "
	
	# Message level.
	match level:
		LEVELS.TRACE:
			log_string += "[TRACE]: "
		LEVELS.DEBUG:
			log_string += "[DEBUG]: "
			if not OS.is_debug_build():
				is_print = false
			is_stack_print = true
		LEVELS.WARNING:
			log_string += "[WARNING]: "
			is_stack_print = true
		LEVELS.ERROR:
			log_string += "[ERROR]: "
			is_stack_print = true
		LEVELS.CRITICAL:
			log_string += "[CRITICAL]: "
			is_stack_print = true
	
	# Emitter Name if any.
	if emitter.has_method("get_name"):
		log_string += "[scene: %s] " %emitter.name
	
	# Emitter object ID.
	log_string += str(emitter)
	log_string += " script: "
	
	# Script Path.
	log_string += emitter.get_script().get_path().get_file()
	log_string += " in func "
	
	# Function Name
	log_string += function
	log_string += ": "
	
	# Message
	log_string += message
	
	if not log_string.ends_with("."):
		log_string += "."
	
	# finally print if required
	if is_print:
		print(log_string)
		if is_stack_print:
			print_stack()
		
		# emit signals for UI Logger Console
		match level:
			LEVELS.TRACE:
				emit_signal("trace_logged", log_string)
			LEVELS.DEBUG:
				emit_signal("debug_logged", log_string)
			LEVELS.WARNING:
				emit_signal("warning_logged", log_string)
			LEVELS.ERROR:
				emit_signal("error_logged", log_string)
			LEVELS.CRITICAL:
				emit_signal("critical_logged", log_string)


func _get_time_string() -> String:
	var dt: Dictionary = OS.get_datetime(true)
	var s: String = "%4d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, 
		dt.hour,dt.minute,dt.second]
	return s
