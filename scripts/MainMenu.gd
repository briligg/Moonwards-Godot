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
		options = options.player_opt("server_bot")
	}
	gamestate.player_register(player_data, true) #local player
	gamestate.server_set_mode()
	var worldscene : String = options.scenes.default_multiplayer_join_server
	gamestate.change_scene(worldscene)
