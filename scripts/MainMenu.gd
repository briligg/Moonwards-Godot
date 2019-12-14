extends Control

onready var main_ui : Node = $VBoxContainer

func _ready() -> void:
	if OS.has_feature("Server"):
		_ready_headless()
	else:
		UIManager.register_base_ui(self)
		UIManager._set_current_ui(main_ui)

func _ready_headless() -> void:
	print("Setup headless mode")
	var player_data : Dictionary = {
		name = "Server Bot",
		options = Options.player_opt("server_bot")
	}
	GameState.player_register(player_data, true) #local player
	GameState.server_set_mode()
	var worldscene : String = Options.scenes.default_multiplayer_join_server
	GameState.change_scene(worldscene)
