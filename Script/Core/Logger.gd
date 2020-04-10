extends Node
"""
	Logger Singleton Class Script
	Provides functions for logging of various levels of message to disk.
	
	Usage example:
	
	hint(self, "function_name", "thing went wrong")
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

signal hint_logged(message)
signal warning_logged(message)
signal error_logged(message)

const LOG_DIR: String = "user://logs/"
const LOG_FILE: String = "%s.txt" # _get_time_string()
enum LEVELS {HINT, WARNING, ERROR}

	# Configuration Variables.
var log_level: int = LEVELS.HINT # Lowest level that should be logged
var enabled: bool = true # Log anything at all?
var log_to_disk: bool = true # Log to disk?
var control_quit_behavior: bool = false # Will delay application exist by one frame
var use_builtin_console: bool = true # Will instance a rich text label to log to
var console_canvas_layer: int = 10 # What canvas layer to place the label on
# The rich text label can be accessed through the "toggle_log" action, or F3 if it does not exist

var _f: File = File.new()
var _d: Directory = Directory.new()

var _can_log_to_disk: bool = true
var _file_path: String = ""


func _init() -> void:
	if log_to_disk:
		if not _d.dir_exists(LOG_DIR):
			_make_log_folder()
		
		_init_log_file()


func _notification(what: int) -> void:
	
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_f.close()
		
		if control_quit_behavior:
			get_tree().quit()


func _ready() -> void:
	if control_quit_behavior:
		get_tree().set_auto_accept_quit(false)
	
	if use_builtin_console:
		var n: CanvasLayer = CanvasLayer.new()
		add_child(n)
		n.layer = console_canvas_layer
		n.add_child(LoggerConsole.new(self))

func error_to_string(code : int) -> String:
	return ERRORS[code]

func hint(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.HINT:
		_log_message(LEVELS.HINT, emitter, function, message)


func warning(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.WARNING:
		_log_message(LEVELS.WARNING, emitter, function, message)


func error(emitter: Object, function: String, message: String) -> void:
	if enabled and log_level <= LEVELS.ERROR:
		_log_message(LEVELS.ERROR, emitter, function, message)


func _make_log_folder() -> void:
	var open_err: int = _d.open("user://")
	
	if not open_err == OK:
		print("_ERROR: Logger: _make_log_folder, can't open 'user://'. Error %s. File logging suspended." % open_err)
		_can_log_to_disk = false
		return
	
	var make_err: int = _d.make_dir(LOG_DIR)
	
	if not make_err == OK:
		print("_ERROR: Logger: _make_log_folder, can't make LOG_DIR. Error %s. File logging suspended." % make_err)
		_can_log_to_disk = false
		return


func _init_log_file() -> void:
	var time: String = _get_time_string()
	_file_path = LOG_DIR + (LOG_FILE % time)
	
	var open_err: int = _f.open(_file_path, File.WRITE)
	
	if not open_err == OK:
		print("_ERROR: Logger: _open_log_file, cant open %s. File logging suspended." % _file_path)
		_can_log_to_disk = false
		return
	
	var header_string: String = ProjectSettings.get("application/config/name")
	header_string += " - " + time
	
	_f.store_line(header_string)
	_f.close()


func _log_message(level: int, emitter: Object, function: String, message: String) -> void:
	var log_string: String = ""
	
	log_string += _get_time_string()
	log_string += " - "
	
	# Message level.
	match level:
		LEVELS.HINT:
			log_string += "HINT: "
		LEVELS.WARNING:
			log_string += "WARNING: "
		LEVELS.ERROR:
			log_string += "ERROR: "
	
	# Emitter Name if any.
	if emitter.has_method("get_name"):
		log_string += emitter.name
		log_string += " - "
	
	# Emitter object ID.
	log_string += str(emitter)
	log_string += " - "
	
	# Script Path.
	log_string += emitter.get_script().get_path().get_file()
	log_string += " - "
	
	# Function Name
	log_string += function
	log_string += " - "
	
	# Message
	log_string += message
	
	if not log_string.ends_with("."):
		log_string += "."
	
	match level:
		LEVELS.HINT:
			emit_signal("hint_logged", log_string)
		LEVELS.WARNING:
			emit_signal("warning_logged", log_string)
		LEVELS.ERROR:
			emit_signal("error_logged", log_string)
	
	
	if log_to_disk and _can_log_to_disk:
		_log_to_disk(log_string)


func _log_to_disk(log_string: String) -> void:
	# warning-ignore:return_value_discarded
	_f.open(_file_path, File.READ_WRITE)
	_f.seek_end(0)
	_f.store_line(log_string)
	_f.close()


func _get_time_string() -> String:
	var datetime: Dictionary = OS.get_datetime(true)
	var s: String = ""
	# TODO: Use format strings for vertical alignment.
	s += str(datetime.year, "-")
	s += str(datetime.month, "-")
	s += str(datetime.day, "-")
	s += str(datetime.hour, "-")
	s += str(datetime.minute, "-")
	s += str(datetime.second)
	return s


class LoggerConsole:
	extends RichTextLabel
	
	var _use_logger_key: bool = false
	
	
	func _init(creator: Node) -> void:
		# Control
		visible = false
		set_anchors_and_margins_preset(Control.PRESET_WIDE)
		focus_mode = Control.FOCUS_NONE
		mouse_filter = Control.MOUSE_FILTER_PASS
		
		# RichTextLabel
		scroll_following = true
		scroll_active = false
		bbcode_enabled = true
		
		# LoggerConsole
		_use_logger_key = InputMap.has_action("toggle_logger")
		
		# warning-ignore:return_value_discarded
		creator.connect("hint_logged", self, "_on_hint_logged")
		# warning-ignore:return_value_discarded
		creator.connect("warning_logged", self, "_on_warning_logged")
		# warning-ignore:return_value_discarded
		creator.connect("error_logged", self, "_on_error_logged")
	
	
	func _input(event: InputEvent) -> void:
		if _use_logger_key:
			if event.is_action_pressed("toggle_logger"):
				visible = !visible
		
		elif event is InputEventKey and event.scancode == KEY_F3 and event.pressed:
			visible = !visible
	
	
	func _on_hint_logged(message) -> void:
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += message
	
	
	func _on_warning_logged(message) -> void:
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += "[color=yellow]" + message + "[/color]"
	
	
	func _on_error_logged(message) -> void:
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += "[color=red]" + message + "[/color]"
	
