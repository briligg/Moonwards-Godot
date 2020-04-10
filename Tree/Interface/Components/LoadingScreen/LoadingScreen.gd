extends Control

func _ready() -> void:
	Lobby.connect("loading_progress", self, "_set_progress_bar")
	Lobby.connect("loading_error", self, "_loading_error")
	#UIManager.register_base_ui(self)
	#UIManager._set_current_ui($Control)

func _set_progress_bar(var progress: float) -> void:
	$Control/ProgressBar.value = progress

func _loading_error(var message: String) -> void:
	$Control/Label.text += str(message)
