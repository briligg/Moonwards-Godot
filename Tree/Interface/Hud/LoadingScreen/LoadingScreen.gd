extends Control

func _ready() -> void:
	Signals.Resources.connect(Signals.Resources.LOADING_PROGRESSED, self, "_set_progress_bar")

func _set_progress_bar(var progress: float) -> void:
	$Control/ProgressBar.value = progress

func _loading_error(var message: String) -> void:
	$Control/Label.text += str(message)
