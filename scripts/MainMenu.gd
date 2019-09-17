extends Control

var scenes : Dictionary = {
	UpdateUI = preload("res://assets/UI/Update/Updating_UI.tscn")
	}

var result : int
var debug_id : String = "Main Menu"
signal Update_finished(result)

func _ready_headless() -> void:
	printd("Setup headless mode")
	
	var player_data = options.player_opt("server_bot")
	gamestate.player_register(player_data, true) #local player
	gamestate.server_set_mode()
	var worldscene = options.scenes.default_multiplayer_headless_scene
	gamestate.change_scene(worldscene)

func _ready() -> void:
	UIManager.register_base_ui(self)

	if utils.feature_check_updater():
		UIManager.ui_event(UIManager.UI_EVENTS.QUEUE_UI, "res://core/update/scenes/UpdateUI.tscn")
		yield(get_tree(), "idle_frame")
		printd("Set updater server")
		options.Updater = UIManager._current_ui.RunUpdateServer()
		return

	if utils.feature_check_server():
		_ready_headless()
		return

	if options.get("updater/client", "check_at_startup", true):
		$VBoxContainer/UpdateUI.visible = true
		UIManager._set_current_ui($VBoxContainer)
		$VBoxContainer/UpdateUI.connect("continue_pressed",self,"_on_continue_pressed")
		var checker = options.get("Update info", "available", false)
		connect("Update_finished",self,"_on_update_finished")
		if checker:
			$VBoxContainer/UI/MainUI/ButtonsContainer/About/UpdateAvailable.show()
			$VBoxContainer/UpdateUI.queue_free()
		else:
			check_for_update()
	else:
		if $VBoxContainer/UpdateUI:
			$VBoxContainer/UpdateUI.queue_free()


func check_for_update() -> void:
	
	var Progress = $VBoxContainer/UpdateUI/VBoxContainer/ProgressBar

	options.Updater.root_tree = get_tree()
	var res = options.Updater.ui_ClientCheckUpdate()
	var indicator = $VBoxContainer/UI/MainUI/ButtonsContainer/About/UpdateAvailable
	if res["state"] == "gathering":
		Progress.value = 25
		yield(options.Updater, "chain_ccu")
		Progress.value = 50
		res = options.Updater.ui_ClientCheckUpdate()
		Progress.value = 100
		if $VBoxContainer/UI/MainUI/ButtonsContainer/About/UpdateAvailable == null:
			yield(UIManager,"back_to_base_ui")
		match res["update_data"]:
			true:
				printd("Update available")
				
				indicator.show()
				
				result = 1
			false:
				indicator.hide()
				printd("No update available")
				
				result = 0
			null:
				
				printd("Error occurred")
				result = -1
				
	printd("end gathering: %s" % res)
	emit_signal("Update_finished", result)
	
	

func _on_update_finished(result : int) -> void:
	var Status = $VBoxContainer/UpdateUI/VBoxContainer/Header
	if not Status is Label:
		yield(get_node("/root/UIManager"), "back_to_base_ui")
		yield(get_tree(),"idle_frame")
	if Status == null:
		Status = $VBoxContainer/UpdateUI/VBoxContainer/Header
		yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	if result == 1:
		Status.text = "There's an update available"
		options.set("Update info", true,"available")
	if result == 0:
		Status.text = "There are no updates available"
		options.set("Update info", false,"available")
	if result == -1:
		Status.text = "An error occurred"
		options.set("Update info", null,"available")
	$VBoxContainer/UpdateUI/VBoxContainer/Status.disabled = false
	var Date = OS.get_datetime()
	options.set("Update info",  str(Date.get("hour")), "hour")
	options.set("Update info",  str(Date.get("minute")), "minute")
	options.set("Update info",  str(Date.get("second")), "second")
	options.set("Update info",  str(Date.get("year")), "year")
	options.set("Update info",  str(Date.get("month")), "month")
	options.set("Update info",  str(Date.get("day")), "day")
	options.save()

func _on_continue_pressed() -> void:
	if result == 1:
		$VBoxContainer.show()
		$VBoxContainer/UpdateUI.queue_free()
		UIManager.next_ui(scenes.UpdateUI)
	else:
		$VBoxContainer.show()
		$VBoxContainer/UpdateUI.queue_free()


func printd(s):
	logg.print_fd(debug_id, s)
