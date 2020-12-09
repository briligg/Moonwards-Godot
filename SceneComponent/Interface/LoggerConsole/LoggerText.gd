extends RichTextLabel


const TRACE = 0
const DEBUG = 1
const WARNING = 2
const ERROR = 4
const CRITICAL = 8

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

#Determines whether we should alternate the line or not.
var trace_alternate : bool = false
var debug_alternate : bool = false
var warning_alternate : bool = false
var error_alternate : bool = false
var critical_alternate : bool = false

var trace_text : PoolStringArray = PoolStringArray()
var debug_text : PoolStringArray = PoolStringArray()
var warning_text : PoolStringArray = PoolStringArray()
var error_text : PoolStringArray = PoolStringArray()
var critical_text : PoolStringArray = PoolStringArray()

#This determines if we should write to the console when a log is received.
var trace_active : bool = true
var debug_active : bool = true
var warning_active : bool = true
var error_active : bool = true
var critical_active : bool = true

#This stores all log entries so that they can be displayed when toggled.
var message_type_history : Array = []

func _get_right_of_date(message : String) -> String :
	message = message.right(message.find("]", 0) + 1)
	return message

func _ready() -> void :
	call_deferred("deferred_ready")

func _on_trace_logged(message) -> void:
	message = _get_right_of_date(message)
	if trace_alternate :
		message = "[color=#FFFFFF]"+message+"[/color]"
		trace_alternate = false
	else :
		message = "[color=#BBBBBB]"+message+"[/color]"
		trace_alternate = true
	
	#Write to the logger console if our boolean is true.
	if trace_active :
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += message
	
	trace_text.append("\n" + message)
	message_type_history.append(TRACE)

func _on_debug_logged(message) -> void:
	message = _get_right_of_date(message)
	if debug_alternate :
		message = "[color=#1414FF]"+message+"[/color]"
		debug_alternate = false
	else :
		message = "[color=#5050FF]"+message+"[/color]"
		debug_alternate = true
	
	#Write to the logger console if our boolean is true.
	if debug_active :
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += "[color=#03FC8C]" + message + "[/color]"
		
	debug_text.append("\n" + message)
	message_type_history.append(DEBUG)

func _on_warning_logged(message) -> void:
	if warning_alternate :
		message = "[color=#FFEF00]"+message+"[/color]"
		warning_alternate = false
	else :
		message = "[color=#CCAC00]"+message+"[/color]"
		warning_alternate = true
	
	#Write to the logger console if our boolean is true.
	if warning_active :
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += "[color=yellow]" + message + "[/color]"
		
	warning_text.append("\n" + message)
	message_type_history.append(WARNING)

func _on_error_logged(message) -> void:
	message = _get_right_of_date(message)
	if error_alternate :
		message = "[color=#FF0000]"+message+"[/color]"
		error_alternate = false
	else :
		message = "[color=#FF5555]"+message+"[/color]"
		error_alternate = true
	
	#Write to the logger console if our boolean is true.
	if error_active :
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += "[color=#FC5603]" + message + "[/color]"
		
	error_text.append("\n" + message)
	message_type_history.append(ERROR)

func _on_critical_logged(message) -> void:
	message = _get_right_of_date(message)
	if critical_alternate :
		message = "[color=#00FF10]"+message+"[/color]"
		critical_alternate = false
	else :
		message = "[color=#8FFF8F]"+message+"[/color]"
		critical_alternate = true
	
	#Write to the logger console if our boolean is true.
	if critical_active :
		bbcode_text += "\n" # new_line uses buggy append_bbcode func
		bbcode_text += "[color=red]" + message + "[/color]"
	
	critical_text.append("\n" + message)
	message_type_history.append(CRITICAL)

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
	trace_active = trace
	debug_active = debug
	warning_active = warning
	error_active = error
	critical_active = critical
	
	bbcode_text = ""
					
	#Setup an Array for determine which messages to
	#let through.
	var unfiltered_message_types : Array = []
	if trace: unfiltered_message_types.append(TRACE)
	if debug: unfiltered_message_types.append(DEBUG)
	if warning: unfiltered_message_types.append(WARNING)
	if error: unfiltered_message_types.append(ERROR)
	if critical: unfiltered_message_types.append(CRITICAL)
	
	#These are for placing in the relevant unfiltered messages.
	var trace_at : int = 0
	var debug_at : int = 0
	var warning_at : int = 0
	var error_at : int = 0
	var critical_at : int = 0
	
	#Go through history and check if the message should be filtered
	#or not.
	for type in message_type_history :
		if unfiltered_message_types.has(type) :
			
			#We are an allowed message. Add to LoggerText output
			if type == TRACE && not trace_text.empty() :
				bbcode_text += trace_text[trace_at]
				trace_at += 1
			elif type == DEBUG && not debug_text.empty() :
				bbcode_text += debug_text[debug_at]
				debug_at += 1
			elif type == WARNING && not warning_text.empty() :
				bbcode_text += warning_text[warning_at]
				warning_at += 1
			elif type == ERROR && not error_text.empty() :
				bbcode_text += error_text[error_at]
				error_at += 1
			elif type == CRITICAL && not critical_text.empty() :
				bbcode_text += critical_text[critical_at]
				critical_at += 1
				
	

