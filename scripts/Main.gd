extends Control

export(String) var SceneToLoad : String = "res://World.tscn"
export(String) var SceneOptions : String = "res://assets/UI/Menu/Options.tscn"

const MultiplayerToLoad = "res://assets/UI/Menu/lobby.tscn"
var current_ui = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("Server"):
		_ready_headless()
		return

	_on_size_changed()
	get_viewport().connect("size_changed",self,"_on_size_changed")

func _ready_headless() -> void:
	print("Setup headless mode")
	var player_data = {
		name = "Server Bot",
		options = Options.player_opt("server_bot")
	}
	GameState.player_register(player_data, true) #local player
	GameState.server_set_mode()
	var worldscene = Options.scenes.default_multiplayer_headless_scene
	GameState.change_scene(worldscene)

func _on_size_changed() -> void:
	var Newsize = get_viewport().get_visible_rect().size
	rect_scale = Vector2(1,1)*(Newsize.y/rect_size.y)

func _on_Run_pressed() -> void:
	$ui/MainUI.hide()
	$ui/ProgressBar.show()
	$load_timer.start()

func _on_Timer_timeout() -> void:
	var worldscene = Options.scenes.default_run_scene
	GameState.change_scene(worldscene)

func _on_Help_pressed() -> void:
	$ui/MainUI/InstructionsContainer.visible = !$ui/MainUI/InstructionsContainer.visible

func _on_RunNet_pressed() -> void:
	$ui/MainUI.hide()
	$ui/PlayerSettings.hide()
	var  mScene = ResourceLoader.load(MultiplayerToLoad)
	var loads = mScene.instance()
	loads.name = "lobby"
	$ui/Logo.hide()
	get_tree().get_root().add_child(loads)

func _on_Options_pressed() -> void:
	if get_tree().get_root().has_node("Options"):
		get_tree().get_root().get_node("Options").show()
	else:
		var options = ResourceLoader.load(SceneOptions)
		options = Options.instance()
		options.name = "Options"
		get_tree().get_root().add_child(options)

func OnUIEvent(var event : String) -> void:
	if event == "Back":
		current_ui.disconnect("ui_event", self, "OnUIEvent")
		$ui/MainUI.show()
		current_ui.hide()
		current_ui = null

func _on_CfgPlayer_pressed() -> void:
	switch_ui($ui/PlayerSettings)

func switch_ui(var new_ui : Node) -> void:
	$ui/MainUI.hide()
	current_ui = new_ui
	current_ui.show()
	current_ui.connect("ui_event", self, "OnUIEvent")
