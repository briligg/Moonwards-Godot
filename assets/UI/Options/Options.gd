extends Control

signal close
signal save
var signal_close = false

const id = "Options.gd"
func printd(s):
	logg.print_filtered_message(id, s)

func get_tab_index():
	return $TabContainer.current_tab

func set_tab_index(index):
	$TabContainer.current_tab = index

func close():
	options.set("state", $TabContainer.current_tab, "menu_options_tab")
	emit_signal("save")
	if not signal_close:
		get_tree().get_root().remove_child(self)
	else:
		emit_signal("close")

func _ready():
	print("option control ready")
	var button
	button = $TabContainer/Dev/VBoxContainer/tAreas
	button.pressed = options.get("dev", "enable_areas_lod")
	button = $TabContainer/Dev/VBoxContainer/tCollisionShapes
	button.pressed = options.get("dev", "enable_collision_shapes")
	button = $TabContainer/Dev/VBoxContainer/tFPSLim
	button.pressed = options.get("dev", "3FPSlimit")
	button = $TabContainer/Dev/VBoxContainer/sFPSLim
	button.value = options.get("dev", "3FPSlimit_value")
	button.connect("changed", self, "set_fps_limit")
	button = $TabContainer/Dev/VBoxContainer/tDecimate
	button.pressed = options.get("dev", "hide_meshes_random")
	button = $TabContainer/Dev/VBoxContainer/sDecimatePercent
	button.value = options.get("dev", "decimate_percent")
	button.connect("changed", self, "set_decimate_percent")
	
	button = $TabContainer/Dev/VBoxContainer/tLodManager
	button.pressed = options.get("dev", "TreeManager")
	button = $TabContainer/Dev/VBoxContainer/sHBoxAspect
	button.value = options.get("LOD", "lod_aspect_ratio")
	button.connect("changed", self, "set_lod_aspect_ratio")
	
	button = $TabContainer/Dev/VBoxContainer/tPMonitor
	button.pressed = options.get("_state_", "perf_mon", false)
	
	button = $TabContainer/Dev/VBoxContainer/sPlayerSpeed
	init_playerspeed_control(button)
	
	button = $TabContainer/Dev/VBoxContainer/SelectFlyCamera
	for i in range(options.fly_cameras.size()):
		button.add_item(options.fly_cameras[i].label, i)
	button.button.selected = options.get("dev", "flycamera", 0)
	button.connect("changed", self, "set_fly_camera")

func _get_player():
	var res
	var tree = get_tree()
	var pg = options.player_opt.player_group
	if tree.has_group(pg):
		var player = tree.get_nodes_in_group(pg)[0]
		if player and utils.obj_has_property(player, "SPEED_SCALE"):
			res = player
	return res

func init_playerspeed_control(button):
	var player = _get_player()
	if player:
		button.enabled = true
		button.value = player.get("SPEED_SCALE")
		button.connect("changed", self, "set_player_speed")
		printd("found player %s at %s, enable speed changes" % [player, player.get_path()])
	else:
		button.enabled = false
		button.value = 0

func set_player_speed(value):
	var player = _get_player()
	if player:
		player.set("SPEED_SCALE", value)
		printd("set_player_speed to value %s" % value)

func _on_GameState_tab_clicked(tab):
	print("_on_GameState_tab_clicked(tab): ", tab)

func _on_GameState_tab_changed(tab):
	print("_on_GameState_tab_changed(tab): ", tab)

func _on_GameState_tab_hover(tab):
	print("_on_GameState_tab_hover(tab): ", tab)

func _on_VBoxContainer_focus_entered():
	print("func _on_VBoxContainer_focus_entered()")
	pass # replace with function body

func _on_tAreas_pressed():
	var button = $TabContainer/Dev/VBoxContainer/tAreas
	debug.e_area_lod(button.pressed)
	options.set("dev", button.pressed, "enable_areas_lod")

func _on_tCollisionShapes_pressed():
	var button = $TabContainer/Dev/VBoxContainer/tCollisionShapes
	debug.e_collision_shapes(button.pressed)
	options.set("dev", button.pressed, "enable_collision_shapes")

func _on_tFPSLim_pressed():
	var button = $TabContainer/Dev/VBoxContainer/tFPSLim
	var button2 = $TabContainer/Dev/VBoxContainer/sFPSLim
	debug.set_3fps(button.pressed, button2.value)
	options.set("dev", button.pressed, "3FPSlimit")

func set_fps_limit(value):
	options.set("dev", value, "3FPSlimit_value")
	var button = $TabContainer/Dev/VBoxContainer/tFPSLim
	debug.set_3fps(button.pressed, value)

func _on_tDecimate_pressed():
	var dp = options.get("dev", "decimate_percent", 90)
	var button = $TabContainer/Dev/VBoxContainer/tDecimate
	if button.pressed:
		debug.hide_nodes_random(dp)
	else:
		debug.hide_nodes_random(0)
	options.set("dev", button.pressed, "hide_meshes_random")

func _on_Exit_pressed():
	UIManager.Back()

func _on_tPMonitor_pressed():
	var button = $TabContainer/Dev/VBoxContainer/tPMonitor
	options.set("dev", button.pressed, "show_performance_monitor")
	debug.show_performance_monitor(button.pressed)

func set_decimate_percent(value):
	options.set("dev", value, "decimate_percent")
	if options.get("dev", "hide_meshes_random", false):
		debug.hide_nodes_random(0)
		debug.hide_nodes_random(value)

func set_lod_aspect_ratio(value):
	options.set("LOD", value, "lod_aspect_ratio")
	var lmp = options.get("_state_", "set_lod_manager")
	if lmp:
		var root = get_tree().current_scene
		root.get_node(lmp).lod_aspect_ratio = value

func _on_tLodManager_pressed():
	var button = $TabContainer/Dev/VBoxContainer/tLodManager
	options.set("dev", button.pressed, "TreeManager")
	debug.set_lod_manager(button.pressed)

func set_fly_camera(value):
	options.set("dev", value, "flycamera")
