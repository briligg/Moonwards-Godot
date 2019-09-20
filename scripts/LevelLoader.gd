extends Node

var path : String = ""
var error : int = OK
var loader : ResourceInteractiveLoader = null
var thread : Thread = Thread.new()
var new_scene : Resource = null
var progress : float = 0.0
var loading_screen_resource : PackedScene= preload("res://assets/UI/Menu/Resources/LoadingScreen.tscn")
var loading_screen : Node = null

func reset() -> void:
	path = ""
	error = OK
	loader = null
	new_scene = null
	progress = 0.0

func start_loading(var path_in : String) -> void:
	reset()
	#Switch to the LoadingScreen before starting the Thread that loads the new level.
	loading_screen = loading_screen_resource.instance()
	gamestate.get_tree().get_root().add_child(loading_screen)
	gamestate.get_tree().current_scene.queue_free()
	gamestate.get_tree().current_scene = loading_screen
	
	path = path_in
	var already : bool = thread.is_active()
	thread.start(self, "threat_start_loading", path)

func thread_start_loading(path : String) -> int:
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		call_deferred('background_loading_done')
		return ERR_CANT_ACQUIRE_RESOURCE
	return thread_loading()
	
func thread_loading() -> int:
	while true:
		if check_loading():
			call_deferred('background_loading_done')
			return error
	return 1

func background_loading_done() -> void:
	var result : bool = thread.wait_to_finish()
	loading_screen.queue_free()
	gamestate.loading_done(result)

func check_loading() -> bool:
	error = loader.poll()
	if error == ERR_FILE_EOF or error == OK:
		progress = loader.get_stage() / max(1.0, (loader.get_stage_count() - 1)) * 100.0
		gamestate.emit_signal("loading_progress", progress)
		if error == ERR_FILE_EOF:
			new_scene = loader.get_resource()
			return true
	else:
		return true
	return false
