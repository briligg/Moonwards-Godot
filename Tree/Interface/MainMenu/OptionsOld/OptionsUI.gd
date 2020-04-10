extends TabContainer

signal close
signal save
var signal_close = false

const id = "Options.gd"

onready var t_Areas = $Dev/MarginContainer/VBoxContainer/tAreas
onready var t_CollisionShapes = $Dev/MarginContainer/VBoxContainer/tCollisionShapes
onready var t_FPSLimit = $Dev/MarginContainer/VBoxContainer/tFPSLim
onready var s_FPSLimit =  $Dev/MarginContainer/VBoxContainer/sFPSLim
onready var t_decimate = $Dev/MarginContainer/VBoxContainer/tDecimate
onready var t_decimate_percent = $Dev/MarginContainer/VBoxContainer/sDecimatePercent
onready var t_Lod_Manager = $Dev/MarginContainer/VBoxContainer/tLodManager
onready var s_HBoxAspect = $Dev/MarginContainer/VBoxContainer/sHBoxAspect
onready var t_PMonitor = $Dev/MarginContainer/VBoxContainer/tPMonitor
onready var s_PlayerSpeed = $Dev/MarginContainer/VBoxContainer/sPlayerSpeed
onready var t_flycam = $Dev/MarginContainer/VBoxContainer/SelectFlyCamera


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
	
#	rect_size = get_parent().rect_size



func get_tab_index() -> int:
	return current_tab

func set_tab_index(index : int) -> void:
	current_tab = index

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
	var pg = Options.player_data.player_group
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
	# originally set limit to value, or 3 if limit was disabled.


func set_decimate_percent(value : int) -> void:
	Options.set("dev", value, "decimate_percent")
	# originally _randomly_ hid mesh instances


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
	# originally did nothing
	Options.set("dev", t_Areas.pressed, "enable_areas_lod")

func _on_tCollisionShapes_pressed() -> void:
	# Originally toggled the enabled property of all collision shapes
	Options.set("dev", t_CollisionShapes.pressed, "enable_collision_shapes")

func _on_tFPSLim_pressed() -> void:
	# originally enabled/disabled fps limit
	Options.set("dev", t_FPSLimit.pressed, "3FPSlimit")


func _on_tDecimate_pressed() -> void:
	# originally set mesh nodes to be hidden at random
	Options.set("dev", t_decimate.pressed, "hide_meshes_random")

#func _on_Exit_pressed() -> void:
#	UIManager.Back()

func _on_tPMonitor_pressed() -> void:
	Options.set("dev", t_PMonitor.pressed, "show_performance_monitor")
	# original toggled performance monitor visibility

func _on_tLodManager_pressed() -> void:
	Options.set("dev", t_Lod_Manager.pressed, "TreeManager")
	# originally performed some sort of deep tree search for a lod manager object


