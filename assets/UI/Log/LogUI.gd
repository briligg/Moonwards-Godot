extends Control

onready var text_edit : Node = $TextEdit
export var hint_color : Color = Color(0.0, 1.0, 0.0, 1.0)
export var warning_color : Color = Color(1.0, 0.5, 0.0, 1.0)
export var error_color : Color = Color(1.0, 0.0, 0.0, 1.0)

var hint_enabled = true
var warning_enabled = true
var error_enabled = true

func _ready():
	text_edit.add_keyword_color("_HINT", hint_color)
	text_edit.add_keyword_color("_WARNING", warning_color)
	text_edit.add_keyword_color("_ERROR", error_color)
	read_log_data()

func read_log_data():
	text_edit.text = ""
	for message in Log.log_data:
		add_message(message)

func add_message(var message : Dictionary):
	match message.level:
		Log.LEVEL.HINT:
			add_hint_message(message.log_message)
	
		Log.LEVEL.WARNING:
			add_warning_message(message.log_message)
	
		Log.LEVEL.ERROR:
			add_error_message(message.log_message)

func add_hint_message(var message : String) -> void:
	if hint_enabled: text_edit.text += message + "\n"

func add_warning_message(var message : String) -> void:
	if warning_enabled: text_edit.text += message + "\n"

func add_error_message(var message : String) -> void:
	if error_enabled: text_edit.text += message + "\n"

func _on_HINT_toggled(button_pressed):
	hint_enabled = button_pressed
	read_log_data()

func _on_WARNING_toggled(button_pressed):
	warning_enabled = button_pressed
	read_log_data()

func _on_ERROR_toggled(button_pressed):
	error_enabled = button_pressed
	read_log_data()