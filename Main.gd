extends Node
"""
	Boot Scene Script
	Initializes headless server if required
"""

func _ready() -> void:
	if CmdLineArgs.is_true("server"):
		_run_headless_server()
	else:
		_run_normal()

func _run_normal() -> void:
	get_tree().change_scene(Scene.main_menu)

func _run_headless_server() -> void:
	Signals.Network.emit_signal(Signals.Network.GAME_SERVER_REQUESTED, false)
