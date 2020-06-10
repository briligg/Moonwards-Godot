extends RichTextLabel


func _ready() -> void :
	call_deferred("deferred_ready")

func _on_trace_logged(message) -> void:
	bbcode_text += "\n" # new_line uses buggy append_bbcode func
	bbcode_text += message

func _on_debug_logged(message) -> void:
	bbcode_text += "\n" # new_line uses buggy append_bbcode func
	bbcode_text += "[color=#03fc8c]" + message + "[/color]"

func _on_warning_logged(message) -> void:
	bbcode_text += "\n" # new_line uses buggy append_bbcode func
	bbcode_text += "[color=yellow]" + message + "[/color]"

func _on_error_logged(message) -> void:
	bbcode_text += "\n" # new_line uses buggy append_bbcode func
	bbcode_text += "[color=#fc5603]" + message + "[/color]"

func _on_critical_logged(message) -> void:
	bbcode_text += "\n" # new_line uses buggy append_bbcode func
	bbcode_text += "[color=red]" + message + "[/color]"

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



