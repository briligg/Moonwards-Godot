extends Control

signal close
signal save
var signal_close = false

const id = "Options.gd"

onready var t_Areas = $TabContainer/Dev/VBoxContainer/tAreas
onready var t_CollisionShapes = $TabContainer/Dev/VBoxContainer/tCollisionShapes
onready var t_FPSLimit = $TabContainer/Dev/VBoxContainer/tFPSLim
onready var s_FPSLimit =  $TabContainer/Dev/VBoxContainer/sFPSLim
onready var t_decimate = $TabContainer/Dev/VBoxContainer/tDecimate
onready var t_decimate_percent = $TabContainer/Dev/VBoxContainer/sDecimatePercent
onready var t_Lod_Manager = $TabContainer/Dev/VBoxContainer/tLodManager
onready var s_HBoxAspect = $TabContainer/Dev/VBoxContainer/sHBoxAspect
onready var t_PMonitor = $TabContainer/Dev/VBoxContainer/tPMonitor
onready var s_PlayerSpeed = $TabContainer/Dev/VBoxContainer/sPlayerSpeed
onready var t_flycam = $TabContainer/Dev/VBoxContainer/SelectFlyCamera
onready var tabs = $TabContainer

func _ready() -> void:
	Log.hint(self, "_ready", "option control ready")
	t_Areas.pressed = Options.get("dev", "enable_areas_lod", true)
	t_CollisionShapes.pressed = Options.get("dev", "enable_collision_shapes", true)
	t_FPSLimit.pressed = Options.get("dev", "3FPSlimit", true)
	s_FPSLimit.value = Options.get("dev", "3FPSlimit_value", 30)
	s_FPSLimit.connect("changed", self, "set_fps_limit")
	t_decimate.pressed = Options.get("dev", "hide_meshes_random", false)
	t_decimate_percent.value = Options.get("dev", "decimate_percent", 0)
	t_decimate_percent.connect("changed", self, "set_decimate_percent")
	
	t_Lod_Manager.pressed = Options.get("dev", "TreeManager", true)
	s_HBoxAspect.value = Options.get("LOD", "lod_aspect_ratio", 2)
	s_HBoxAspect.connect("changed", self, "set_lod_aspect_ratio")
 
	t_PMonitor.pressed = Options.get("_state_", "perf_mon", false)
	
	
	init_playerspeed_control(s_PlayerSpeed)
	
	for i in range(Options.fly_cameras.size()):
		t_flycam.add_item(Options.fly_cameras[i].label, i)
	t_flycam.button.selected = Options.get("dev", "flycamera", 0)
	t_flycam.connect("changed", self, "set_fly_camera")



func get_tab_index() -> int:
	return tabs.current_tab

func set_tab_index(index : int) -> void:
	tabs.current_tab = index

func close() -> void:
	Options.set("state", $TabContainer.current_tab, "menu_options_tab")
	emit_signal("save")
	if not signal_close:
		get_tree().get_root().remove_child(self)
	else:
		emit_signal("close")



func get_player() -> Spatial:
	var res
	var tree = get_tree()
	var pg = Options.player_opt.player_group
	if tree.has_group(pg):
		var player = tree.get_nodes_in_group(pg)[0]
		if player and NodeUtilities.obj_has_property(player, "SPEED_SCALE"):
			res = player
	return res

func init_playerspeed_control(button : Control) -> void:
	var player = get_player()
	if player:
		button.enabled = true
		button.value = player.get("SPEED_SCALE")
		button.connect("changed", self, "set_player_speed")
		Log.hint(self, "init_playerspeed_control", str("found player", player, "at", player.get_path(), ", enable speed changes"))
	else:
		button.enabled = false
		button.value = 0

func set_fps_limit(value : int) -> void:
	Options.set("dev", value, "3FPSlimit_value")
	Debugger.set_3fps(t_FPSLimit.pressed, value)
	
func set_decimate_percent(value : int) -> void:
	Options.set("dev", value, "decimate_percent")
	if Options.get("dev", "hide_meshes_random", false):
		Debugger.hide_nodes_random(0)
		Debugger.hide_nodes_random(value)

func set_lod_aspect_ratio(value : int) -> void:
	Options.set("LOD", value, "lod_aspect_ratio")
	var lmp = Options.get("_state_", "set_lod_manager")
	if lmp:
		var root = get_tree().current_scene
		root.get_node(lmp).lod_aspect_ratio = value

func set_fly_camera(value : int) -> void:
	Options.set("dev", value, "flycamera")

func set_player_speed(value: float) -> void:
	var player = get_player()
	if player:
		player.set("SPEED_SCALE", value)
		Log.hint(self, "set_player_speed",str("set_player_speed to value : ", value))

func _on_tAreas_pressed() -> void:
	Debugger.e_area_lod(t_Areas.pressed)
	Options.set("dev", t_Areas.pressed, "enable_areas_lod")

func _on_tCollisionShapes_pressed() -> void:
	Debugger.e_collision_shapes(t_CollisionShapes.pressed)
	Options.set("dev", t_CollisionShapes.pressed, "enable_collision_shapes")

func _on_tFPSLim_pressed() -> void:
	Debugger.set_3fps(t_FPSLimit.pressed, s_FPSLimit.value)
	Options.set("dev", t_FPSLimit.pressed, "3FPSlimit")


func _on_tDecimate_pressed() -> void:
	var dp = Options.get("dev", "decimate_percent", 90)
	if t_decimate.pressed:
		Debugger.hide_nodes_random(dp)
	else:
		Debugger.hide_nodes_random(0)
	Options.set("dev", t_decimate.pressed, "hide_meshes_random")

func _on_Exit_pressed() -> void:
	UIManager.Back()

func _on_tPMonitor_pressed() -> void:
	Options.set("dev", t_PMonitor.pressed, "show_performance_monitor")
	Debugger.show_performance_monitor(t_PMonitor.pressed)

func _on_tLodManager_pressed() -> void:
	Options.set("dev", t_Lod_Manager.pressed, "TreeManager")
	Debugger.set_lod_manager(t_Lod_Manager.pressed)


