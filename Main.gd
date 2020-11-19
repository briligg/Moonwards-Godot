extends Node
"""
	Boot Scene Script
	Initializes headless server if required
"""

func _ready() -> void:
	if CmdLineArgs.is_true("server"):
		_run_headless_server()
		VisualServer.viewport_set_active(get_tree().get_root().get_viewport_rid(), false)
	else:
		_run_normal()

func _run_normal() -> void:
	get_tree().change_scene(Scene.main_menu)

func _run_headless_server() -> void:
	Signals.Network.emit_signal(Signals.Network.GAME_SERVER_REQUESTED, false)
