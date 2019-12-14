extends Node
var id : int

var camera_ready_path : String
var camera_ready_oldcamera : Camera
var camera : Camera
var camera_path : String
var camera_used : int
var active : bool = false
var pf_path : String
var hidden_nodes : Array = []
var hidden_nodes_prob : float

func _ready() -> void:
	randomize()
	id = randi()

	NodeUtilities.bind_signal("scene_change", "", GameState, self, NodeUtilities.MODE.CONNECT)
	NodeUtilities.bind_signal("node_added", "", get_tree(), self, NodeUtilities.MODE.CONNECT)
	NodeUtilities.bind_signal("node_removed", "", get_tree(), self, NodeUtilities.MODE.CONNECT)

	debug_apply_options()
	#List Features
	log_features_list()
	#removes sticky and unreliable pressing release for key events, at slower FPS
	Input.set_use_accumulated_input(false)

func _input(event : InputEvent) -> void:

	if event.is_action_pressed("debug_active_cameras"):
		log_active_cameras()
	if event.is_action_pressed("debug_camera_to_local_player"):
		set_active_camera()
	if event.is_action_pressed("debug_test_rpc"):
		rpc("test_remote_call")
	if event.is_action_pressed("debug_force_camera"):
		camera_ready(true)
	if event.is_action_pressed("debug_player_list"):
		log_current_players()
	if event.is_action_pressed("debug_dir_list"):
		log_dir_contents()
		log_groups()
	if event.is_action_pressed("mouse_toggle"):
		mouse_toggle()






func debug_apply_options() -> void:
	yield(get_tree(), "idle_frame")
	Log.hint(self, "sebug_apply_options", "Apply Options to new player scene")
	e_collision_shapes(Options.get("dev", "enable_collision_shapes", false))
	hidden_nodes = []
	if Options.get("dev", "hide_meshes_random"):
		hide_nodes_random(Options.get("dev", "decimate_percent"))
	set_3fps(Options.get("dev", "3FPSlimit", true), Options.get("dev", "3FPSlimit_value", 30))
	e_area_lod(Options.get("dev", "enable_areas_lod", true))
	set_lod_manager(Options.get("dev", "TreeManager", false))

	#insert some camera
	if not Options.get_tree_opt("NoCamera"):
		camera_ready()

func camera_ready(force : bool = false) -> void:
	#The Debugger camera can not be spawned when the chat or other UI is active.
	if UIManager.has_ui and not camera_ready_path:
		return

	yield(get_tree(), "idle_frame")
	var root = get_tree().current_scene
	if camera_ready_path:
		root.get_node(camera_ready_path).queue_free()

		if camera_ready_oldcamera:
			camera_ready_oldcamera.current = true
		camera_ready_oldcamera = null
		camera_ready_path = ''
		yield(get_tree(), "idle_frame")
		UIManager.clear_ui()
		return


	camera_ready_oldcamera = get_tree().root.get_viewport().get_camera()
	if camera_ready_oldcamera:
		active = true
	if not active or force:
		camera_used = Options.get("dev", "flycamera", 0)
		camera_path = Options.fly_cameras[camera_used].path
		camera = load(camera_path).instance()
		root.add_child(camera)
		camera_ready_path = root.get_path_to(camera)
		camera.current = true
		if active:
			Log.hint(self, "camera_ready", "sync camera position with old camera")
			camera.global_transform = camera_ready_oldcamera.global_transform
		Log.hint(self, "camera_ready",str("added fly camera to scene, index ", camera_used))







func set_active_camera() -> void:
	Log.hint(self, "set_active_camera",str("set camera to local player: ", GameState.local_id))
	GameState.player_local_camera()


func set_3fps(enable : bool, value : int = 3) -> void:
	if enable:
		Log.hint(self, "set_3fps", str("Debugger set FPS to ", round(value)))
		Engine.target_fps = round(value)
	else:
		Log.hint(self, "set_3fps", "Debugger set FPS to 3")
		Engine.target_fps = 3

func e_area_lod(enable : bool = true) -> void:
	pass

func e_collision_shapes(enable : bool = true):
	var root = NodeUtilities.scene
	var cs_objects = Utilities.get_cs_list_cs(root)
	Log.hint(self, "e_collision_shapes", str("e_collision_shape(enable=", enable, "), found : ", cs_objects.size()))
	for p in cs_objects:
		var obj = root.get_node(p)
		obj.disabled = !enable

func hide_obj_check(root : Node, path : NodePath) -> bool:
	var obj = root.get_node(path)
	var hide = true
	if NodeUtilities.obj_has_groups(obj, NodeUtilities.cs_options.hide_protect):
		hide = false
	if hide and obj.get_child_count() > 0:
		var nodes = NodeUtilities.get_nodes_type(obj, "MeshInstance", true)
		for p in nodes:
			if obj.get_node(p).visible:
				hide = false
				break
	return hide


#Hide MeshInstance nodes with a chance defined by probability

func hide_nodes_random(probability : int = -1) -> void:
	var root = get_tree().current_scene
	if probability == -1:
		probability = Options.get("decimate", "probability", 80)
	if probability == 0:
		#unhide all nodes
		Log.hint(self, "hide_nodes_random", str("unhide nodes (", hidden_nodes.size(), ")" ))
		for p in hidden_nodes:
			root.get_node(p).visible = true
		hidden_nodes = []
		hidden_nodes_prob = 0
		return

	var nodes : Array = NodeUtilities.get_nodes_type(root, "MeshInstance", true)
	Log.hint(self, "hide_nodes_random", str("hide nodes, total(", nodes.size(), ") already hidden(", hidden_nodes.size(), ") probability(", probability, ")" ))
	if nodes.size() < 1 :
		return
	nodes.shuffle()
	for p in nodes:
		if not hidden_nodes.has(p):
			var hide = (randi() % 100 <= probability)
			if hide and hide_obj_check(root, p):
				root.get_node(p).visible = false
				hidden_nodes.append(p)
	Log.hint(self, "hide_nodes_random", str("hide nodes, total(", nodes.size(), ") already hidden(", hidden_nodes.size(), ") probability(", probability, ")" ))


func show_performance_monitor(enable : bool) -> void:
	if enable and not pf_path:
		var packedscene : PackedScene = ResourceLoader.load("res://scripts/PerformanceMonitor.tscn")
		var root : Node = get_tree().current_scene
		var pf : Node = packedscene.instance()
		root.add_child(pf)
		pf_path = root.get_path_to(pf)
		Options.set("_state_", true, "perf_mon")
	if not enable and pf_path:
		var root = get_tree().current_scene
		var pf = root.get_node(pf_path)
		if pf:
			pf.queue_free()
		pf_path = ""
		Options.set("_state_", false, "perf_mon")

func set_lod_manager(enable : bool) -> void:
	var slm = Options.get("_state_", "set_lod_manager")
	var root = get_tree().current_scene
	if slm == null:
		#find if lod manager is present in scene
		Log.hint(self, "set_lod_manager", "Look for existing TreeManager")
		for p in NodeUtilities.get_nodes_type(root, "Node", true):
			var obj = root.get_node(p)
			if obj.script and obj.get("id") and obj.id == "TreeManager":
				slm = p
				Options.set("_state_", p, "set_lod_manager")
				Log.hint(self, "set_lod_manager",str("found TreeManager at ", p))
				break
		if enable == null:
			#just find if there is lod manager in the tree
			Log.hint(self, "set_lod_manager", "end search for LodManager")
			return

	if not enable:
		if slm:
			var tm = root.get_node(slm)
			if tm == null:
				return
			tm.enabled = false
#		else:
			Log.hint(self, "set_lod_manager", "set_lod_manager, attempt to disable notexisting tree manager")
		return #nothing to do here

	if slm == null:
		#create/add proper node
		Log.hint(self, "set_lod_manager", "Load TreeManager")
		var tm_path = Options.get("dev", "lod_manager_path", "res://scripts/TreeManager.tscn")
		var tm = ResourceLoader.load(tm_path)
		tm = tm.instance()
		root.add_child(tm)
		slm = root.get_path_to(tm)
		Options.set("_state_", slm, "set_lod_manager")

	var tm = root.get_node(slm)
	if Options.get("LOD", "lod_aspect_ratio"):
		tm.lod_aspect_ratio = Options.get("LOD", "lod_aspect_ratio")
	tm.enabled = enable
	
func log_active_cameras() -> void:
	var root = get_tree().current_scene
	var cameras = NodeUtilities.get_nodes_type(root, "Camera", true)
	for p in cameras:
		Log.hint(self, "print_active_camera", str(p, "(", root.get_node(p).current, ")"))

func log_features_list(enabled_only : bool = true) -> void:
	var features = [
		{ opt = "Android", hint = "Running on Android" },
		{ opt = "HTML5", hint = "Running on HTML5" },
		{ opt = "JavaScript", hint = "JavaScript singleton is available" },
		{ opt = "OSX", hint = "Running on macOS" },
		{ opt = "iOS", hint = "Running on iOS" },
		{ opt = "UWP", hint = "Running on UWP" },
		{ opt = "Windows", hint = "Running on Windows" },
		{ opt = "X11", hint = "Running on X11 (Linux/BSD desktop)" },
		{ opt = "Server", hint = "Running on the headless server platform" },
		{ opt = "Debugger", hint = "Running on a Debugger build (including the editor)" },
		{ opt = "release", hint = "Running on a release build" },
		{ opt = "editor", hint = "Running on an editor build" },
		{ opt = "standalone", hint = "Running on a non-editor build" },
		{ opt = "64", hint = "Running on a 64-bit build (any architecture)" },
		{ opt = "32", hint = "Running on a 32-bit build (any architecture)" },
		{ opt = "x86_64", hint = "Running on a 64-bit x86 build" },
		{ opt = "x86", hint = "Running on a 32-bit x86 build" },
		{ opt = "arm64", hint = "Running on a 64-bit ARM build" },
		{ opt = "arm", hint = "Running on a 32-bit ARM build" },
		{ opt = "mobile", hint = "Host OS is a mobile platform" },
		{ opt = "pc", hint = "Host OS is a PC platform (desktop/laptop)" },
		{ opt = "web", hint = "Host OS is a Web browser" },
		{ opt = "etc", hint = "Textures using ETC1 compression are supported" },
		{ opt = "etc2", hint = "Textures using ETC2 compression are supported" },
		{ opt = "s3tc", hint = "Textures using S3TC (DXT/BC) compression are supported" },
		{ opt = "pvrtc", hint = "Textures using PVRTC compression are supported" },
		# custom features, Moonwards specific

	]

	if enabled_only:
		Log.hint(self, "features_list", "Print only enabled features")

	for f in features:
		if enabled_only:
			if OS.has_feature(f.opt):
				Log.hint(self, "features_list", str("OS ", f.opt, " has ", OS.has_feature(f.opt)))
		else:
			Log.hint(self, "features_list", str("OS ", f.opt, " has ", OS.has_feature(f.opt)))


func log_current_players() -> void:
	Log.hint(self, "print_current_players","GameState players")
	print(GameState.players)
	for p in GameState.players.keys():
		Log.hint(self, "print_current_players",str("player ", GameState.players[p]))
		Log.hint(self, "print_current_players",str("obj at ", GameState.players[p].obj.get_path()))

func log_groups() -> void:
	#get_nodes_in_group("LODElement)
	Log.hint(self, "print_groups", "List of nodes in LODElement group")
	for obj in get_tree().get_nodes_in_group("LODElement"):
		Log.hint(self, "print_groups", obj.get_path())
	Log.hint(self, "print_groups", "List of nodes in wall group")
	for obj in get_tree().get_nodes_in_group("wall"):
		Log.hint(self, "print_groups", obj.get_path())
 	for p in get_tree().call_group("LODElement", "get_path"):
 		Log.hint(self, "print_groups", str(p))
 	Log.hint(self, "print_groups", "List of nodes in wall group")
 	for p in get_tree().call_group("wall", "get_path"):
 		Log.hint(self, "print_groups", str(p))

func log_dir_contents(path : String = "res://") -> void:
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				Log.hint(self, "print_dir_contents", dir.get_current_dir() + file_name + "/")
			else:
				Log.hint(self, "print_dir_contents", dir.get_current_dir() + file_name)
			file_name = dir.get_next()
	else:
		Log.hint(self, "print_dir_contents", "An error occurred when trying to access the path.")

func mouse_toggle() -> void:
	match Input.get_mouse_mode():
		Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Log.hint(self, "mouse_toggle","set cursor to captured")
		Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Log.hint(self, "mouse_toggle","set cursor to visible")
		_:
			Log.hint(self, "mouse_toggle", str("Do not know what to do, current mode ",  Input.get_mouse_mode()))
			
########## Extra verbose functions ###########

func _on_tree_change() -> void:
	Log.hint(self, "_on_tree_change", "Debugger treechange")

func _on_node_added(node) -> void:
	Log.hint(self, "_on_node_added", str("added node ", node.get_path()))

func _on_node_removed(node) -> void:
	Log.hint(self, "_on_node_removed", str("node removed: ", node))
	
func _on_scene_change() -> void:
	Log.hint(self, "_on_scene_change" ,"")
	Options.del_state("set_lod_manager")
	debug_apply_options()
################################################