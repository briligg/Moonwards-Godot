extends RichTextLabel


const TRACE = 0
const DEBUG = 1
const WARNING = 2
const ERROR = 3
const CRITICAL = 4

#What the bbcode is for all log messages.
const LOG_STRING:String = "\n[color=%s]%s[/color]" 

#What colors the lines of text are.
export(Color) var trace_color_1  = Color("#FFFFFF")
export(Color) var trace_color_2 = Color("#BBBBBB")
export(Color) var debug_color_1 = Color("#00FF08")
export(Color) var debug_color_2 = Color("#5AFF5A")
export(Color) var warning_color_1 = Color("#FFEF00")
export(Color) var warning_color_2 = Color("#FFEF5D")
export(Color) var error_color_1 = Color("#FFA200")
export(Color) var error_color_2 = Color("#FFC154")
export(Color) var critical_color_1 = Color("#FF0000")
export(Color) var critical_color_2 = Color("#FF5555")

const TYPE_NAMES : Array = ["trace", "debug", "warning", "error", "critical"]

#Determines whether we should alternate the line or not.
var alternates : Array = [false,false,false,false,false]

var log_messages : PoolStringArray = PoolStringArray()

#This determines if we should write to the console when a log is received.
var actives : Array = [true,true,true,true,true]

#This stores all log entries so that they can be displayed when toggled.
var message_type_history : Array = []

func _get_right_of_date(message : String) -> String :
	message = message.right(message.find("]", 0) + 1)
	return message

func _ready() -> void :
	call_deferred("deferred_ready")

func _add_log_message(message : String, type : int) -> void :
	message = _get_right_of_date(message)
	
	#Color the message based on the color of the message before it.
	if alternates[type] :
		var color_string : String = get(TYPE_NAMES[type]+"_color_1").to_html(false)
		message = LOG_STRING % [color_string, message]
		alternates[type] = false
	else :
		var color_string : String = get(TYPE_NAMES[type]+"_color_2").to_html(false)
		message = LOG_STRING % [color_string, message]
		alternates[type] = true
	
	#Only add the message to the display if it is an active type.
	if actives[type] :
		bbcode_text += message
	
	#Append the new message to the end of the type's text storage array.
	log_messages.append(message)
	message_type_history.append(type)

func _on_trace_logged(message) -> void:
	_add_log_message(message, TRACE)

func _on_debug_logged(message) -> void:
	_add_log_message(message, DEBUG)

func _on_warning_logged(message) -> void:
	_add_log_message(message, WARNING)

func _on_error_logged(message) -> void:
	_add_log_message(message, ERROR)

func _on_critical_logged(message) -> void:
	_add_log_message(message, CRITICAL)

func deferred_ready() -> void :
	var logger : Node = get_parent().get_parent().get_parent()
	logger.connect("trace_logged", self, "_on_trace_logged")
	# warning-ignore:return_value_discarded
	logger.connect("debug_logged", self, "_on_debug_logged")
	# warning-ignore:return_value_discarded
	logger.connect("warning_logged", self, "_on_warning_logged")
	# warning-ignore:return_value_discarded
	logger.connect("error_logged", self, "_on_error_logged")
	# warning-ignore:return_value_discarded
	logger.connect("critical_logged", self, "_on_critical_logged")

#Filter out messages from levels you do not care about.
func filter_text(trace : bool, debug : bool, warning : bool,
					error : bool, critical : bool) -> void :
	#Store what log severities are active and which are not.
	actives[TRACE] = trace
	actives[DEBUG] = debug
	actives[WARNING] = warning
	actives[ERROR] = error
	actives[CRITICAL] = critical
	
	bbcode_text = ""
					
	#Setup an Array for determining which messages to
	#let through.
	var unfiltered_message_types : Array = []
	if trace: unfiltered_message_types.append(TRACE)
	if debug: unfiltered_message_types.append(DEBUG)
	if warning: unfiltered_message_types.append(WARNING)
	if error: unfiltered_message_types.append(ERROR)
	if critical: unfiltered_message_types.append(CRITICAL)
	
	#Go through history and check if the message should be filtered
	#or not.
	var at : int = 0
	for type in message_type_history :
		if unfiltered_message_types.has(type) :
			#We are an allowed message. Add to LoggerText output
			bbcode_text += log_messages[at]
		at += 1

