extends Node

var is_chat_active: bool = false

func _ready() -> void:
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_FINISHED, self, "on_finished_typing")
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_STARTED, self, "on_started_typing")

func on_started_typing():
	is_chat_active = true

func on_finished_typing():
	is_chat_active = false
