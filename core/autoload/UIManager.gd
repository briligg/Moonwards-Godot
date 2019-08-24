extends Node

var _ui_history_queue = []
var _ui_future_queue = []
var _current_ui = null
var _on_queued_ui = false
var _base_ui = null
var has_ui = false

signal back_to_base_ui

enum UI_EVENTS{
		BACK,
		CREATE_UI,
		QUEUE_UI,
		SET_SETTING,
		DISMISS,
		LOAD_LEVEL,
		JOIN_SERVER,
		RUN_LOCALLY,
		EXIT,
		UPDATE
}

const UI_EVENT_TO_TEXT = ["back", "create_ui", "queue_ui", "set_setting", "dismiss",
		"load_level", "join_server", "run_locally", "exit", "update" ]

func ui_event_to_text(ui_event: int) -> String:
	var text = "none"
	if UI_EVENT_TO_TEXT.size() - 1  > ui_event:
		text = "unknown ui_event(%s)" % ui_event
	else:
		text = UI_EVENT_TO_TEXT[ui_event]
	return text


func _ready() -> void:
	gamestate.connect("scene_change", self, "_change_scene")


func ui_event(ui_event : int, resource = null) -> void:
	assert(UI_EVENTS.values().has(ui_event)) # Replace with error
	
	match ui_event:
		UI_EVENTS.CREATE_UI:
			next_ui(resource)
		UI_EVENTS.QUEUE_UI:
			queue_ui(resource)
		UI_EVENTS.BACK:
			back()
		UI_EVENTS.SET_SETTING:
			set_setting()
		UI_EVENTS.DISMISS:
			dismiss_ui()
		UI_EVENTS.LOAD_LEVEL:
			load_level(resource)
		UI_EVENTS.JOIN_SERVER:
			join_server(resource)
		UI_EVENTS.RUN_LOCALLY:
			run_local(resource)
		UI_EVENTS.EXIT:
			exit()
		UI_EVENTS.UDPATE:
			queue_ui(resource)
		_:
			print("UIManager, no action for %s resource(%s)" % [ui_event_to_text(ui_event), resource])


func set_setting() -> void:
	print("**implement me UIManager::SetSetting")


func _change_scene() -> void:
	_ui_history_queue.clear()
	_ui_future_queue.clear()
	has_ui = false


func can_go_back() -> bool:
	return (_ui_history_queue.size() > 0)


func back() -> void:
	if _ui_history_queue.size() == 1:
		emit_signal("back_to_base_ui")
	
	if not can_go_back():
		return
	
	#Delete the current UI before going back.
	if is_instance_valid(_current_ui):
		_current_ui.queue_free()
	
	_add_previous_ui()


func _add_previous_ui() -> void:
	_base_ui.add_child(_ui_history_queue.front())
	_set_current_ui(_ui_history_queue.pop_front())


func free_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func lock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _queue_current_ui() -> void:
	if is_instance_valid(_current_ui):
		_current_ui.get_parent().remove_child(_current_ui)
		_ui_history_queue.append(_current_ui)


func queue_ui(var resource) -> void:
	if _ui_future_queue.empty() and not _on_queued_ui:
		next_ui(resource)
		_on_queued_ui = true
	else:
		_ui_future_queue.append(resource)


func dismiss_ui():
	# Continue showing the queued UIs.
	if not _ui_future_queue.empty():
		clear_ui()
		_switch_ui(_ui_future_queue.pop_back())
		_on_queued_ui = true
	# If there are no other UIs queued then go back to the previous UI.
	elif can_go_back():
		back()
		_on_queued_ui = false
	# When there is no history then the UI can be removed completely.
	else:
		clear_ui()
		_on_queued_ui = false


func create_ui(var resource) -> Node:
	if resource is String:
		resource = ResourceLoader.load(resource)
	var new_ui = resource.instance()
	return new_ui


func clear_ui() -> void:
	if is_instance_valid(_current_ui):
		_current_ui.queue_free()
	
	_current_ui = null
	has_ui = false
	lock_mouse()


func next_ui(var next_ui) -> void:
	_queue_current_ui()
	_switch_ui(next_ui)


func _switch_ui(var next_ui) -> void:
	var new_ui = create_ui(next_ui)
	_base_ui.add_child(new_ui)
	_set_current_ui(new_ui)
	has_ui = true
	free_mouse()


func register_base_ui(var new_base_ui: Node) -> void:
	# The base UI is the upper most Control Node.
	_base_ui = new_base_ui


func _set_current_ui(var new_ui: Node) -> void:
	# This Node is used to attach all future UI to.
	_current_ui = new_ui


func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		# When pressing escape the future UI queue is used before going back.
		if not _ui_future_queue.empty() and _on_queued_ui:
			dismiss_ui()
		else:
			back()


func request_focus() -> bool:
	if has_ui:
		return false
	else:
		has_ui = true
		return true


func release_focus() -> void:
	has_ui = false


func load_level(var resource) -> void:
	gamestate.load_level(resource)


func join_server(scene: String) -> void:
	if scene == null or scene == "":
		scene = options.scenes.default_multiplayer_join_server

	var player_data = {
		username = options.username
	}
	
	gamestate.player_register(player_data, true, "avatar") #local player
	gamestate.load_level(scene)
	gamestate.client_server_connect(options.join_server_host)


func run_local(scene: String) -> void:
	if scene == null or scene == "":
		scene = options.scenes.default_run_scene

	var player_data = {
		username = options.username
	}
	
	gamestate.player_register(player_data, true, "avatar_local") #local player
	gamestate.load_level(scene)


func exit() -> void:
	get_tree().quit()
