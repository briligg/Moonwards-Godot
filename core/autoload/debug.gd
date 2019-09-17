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
var debug_id : String = "debug.gd"

func printd(s) -> void:
	logg.print_filtered_message(debug_id, s)

func _input(event : InputEvent) -> void:
	#print("debug event: %s" % event)
	if event.is_action_pressed("debug_active_cameras"):
		print_active_cameras()
	if event.is_action_pressed("debug_camera_to_local_player"):
		set_active_camera()
	if event.is_action_pressed("debug_test_rpc"):
		print("call debug remote test")
		rpc("test_remote_call")
	if event.is_action_pressed("debug_force_camera"):
		camera_ready(true)
	if event.is_action_pressed("debug_player_list"):
		print_current_players()
	if event.is_action_pressed("debug_dir_list"):
		#dir_contents()
		print_groups()
	if event.is_action_pressed("mouse_toggle"):
		mouse_toggle()

func _ready() -> void:
	randomize()
	id = randi()
	gamestate.connect("scene_change", self, "on_scene_change")
	
	var tree = get_tree()
# 	tree.connect("tree_changed", self, "on_tree_change")
	tree.connect("node_added", self, "on_node_added")
	tree.connect("node_removed", self, "on_node_removed")
#	tree.connect("idle_frame", self, "tree_idle_frame")
	
	debug_apply_options()
	#List Features
	features_list()
	#removes sticky and unreliable pressing release for key events, at slower FPS
	Input.set_use_accumulated_input(false)
	
func on_tree_change() -> void:
	printd("debug treechange")
func on_node_added(node):
	printd("added node %s" % node.get_path())
func on_node_removed(node):
	printd("node removed: %s" % node)
func tree_idle_frame():
	printd("tree idle frame")

func debug_apply_options() -> void:
	yield(get_tree(), "idle_frame")
	printd("Apply options to new player scene")
	e_collision_shapes(options.get("dev", "enable_collision_shapes"))
	hidden_nodes = []
	if options.get("dev", "hide_meshes_random"):
		hide_nodes_random(options.get("dev", "decimate_percent"))
	set_3fps(options.get("dev", "3FPSlimit"), options.get("dev", "3FPSlimit_value"))
	e_area_lod(options.get("dev", "enable_areas_lod"))
	set_lod_manager(options.get("dev", "TreeManager"))
	
	#insert some camera
	if not options.get_tree_opt("NoCamera"):
		camera_ready()

func camera_ready(force : bool = false) -> void:
	#The debug camera can not be spawned when the chat or other UI is active.
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
		camera_used = options.get("dev", "flycamera", 0)
		camera_path = options.fly_cameras[camera_used].path
		camera = load(camera_path).instance()
		root.add_child(camera)
		camera_ready_path = root.get_path_to(camera)
		camera.current = true
		if active:
			printd("sync camera position with old camera")
			camera.camera.global_transform = camera_ready_oldcamera.global_transform
		printd("added fly camera to scene, index %s" % camera_used)

func on_scene_change() -> void:
	printd("on_scene_change")
	options.del_state("set_lod_manager")
	debug_apply_options()

func user_scene_changed() -> void:
	#reset scene specific things
	pass


func print_active_cameras() -> void:
	var root = get_tree().current_scene
	var cameras = utils.get_nodes_type(root, "Camera", true)
	for p in cameras:
		printd("%s(%s)" % [p, root.get_node(p).current])

func set_active_camera() -> void:
	printd("set camera to local player: %s" % gamestate.local_id)
	gamestate.player_local_camera()

remote func test_remote_call() -> void:
	print("test_remote_call (%s)" % id)

func set_3fps(enable : bool, value : int = 3) -> void:
	if enable:
		printd("debug set FPS to %s" % round(value))
		Engine.target_fps = round(value)
	else:
		printd("debug set FPS to 0")
		Engine.target_fps = 0

func e_area_lod(enable : bool = true) -> void:
	pass

func e_collision_shapes(enable : bool = true):
	var root = utils.scene
	var cs_objects = utils.get_cs_list_cs(root)
	printd("e_collision_shape(enable=%s), found : %s" % [enable, cs_objects.size()])
	for p in cs_objects:
		var obj = root.get_node(p)
		obj.disabled = !enable

func hide_obj_check(root : Node, path : NodePath) -> bool:
	var obj = root.get_node(path)
	var hide = true
	if utils.obj_has_groups(obj, utils.cs_options.hide_protect):
		hide = false
	if hide and obj.get_child_count() > 0:
		var nodes = utils.get_nodes_type(obj, "MeshInstance", true)
		for p in nodes:
			if obj.get_node(p).visible:
				hide = false
				break
	return hide


#Hide MeshInstance nodes with a chance defined by probability

func hide_nodes_random(probability : int = -1) -> void:
	var root = get_tree().current_scene
	if probability == -1:
		probability = options.get("decimate", "probability", 80)
	if probability == 0:
		#unhide all nodes
		print("unhide nodes (%s)" % hidden_nodes.size())
		for p in hidden_nodes:
			root.get_node(p).visible = true
		hidden_nodes = []
		hidden_nodes_prob = 0
		return
	
	var nodes : Array = utils.get_nodes_type(root, "MeshInstance", true)
	print("hide nodes, total(%s) already hidden(%s) probability(%s)" % [nodes.size(), hidden_nodes.size(), probability])
	if nodes.size() < 1 :
		return
	nodes.shuffle()
	
	for p in nodes:
		if not hidden_nodes.has(p):
			var hide = (randi() % 100 <= probability)
			if hide and hide_obj_check(root, p):
				root.get_node(p).visible = false
				hidden_nodes.append(p)
	print("hide nodes, total(%s) already hidden(%s) probability(%s)" % [nodes.size(), hidden_nodes.size(), probability])


func show_performance_monitor(enable : bool) -> void:
	if enable and not pf_path:
		var packedscene : PackedScene = ResourceLoader.load("res://scripts/PerformanceMonitor.tscn")
		var root : Node = get_tree().current_scene
		var pf : Node = packedscene.instance()
		root.add_child(pf)
		pf_path = root.get_path_to(pf)
		options.set("_state_", true, "perf_mon")
	if not enable and pf_path:
		var root = get_tree().current_scene
		var pf = root.get_node(pf_path)
		if pf:
			pf.queue_free()
		pf_path = ""
		options.set("_state_", false, "perf_mon")

func set_lod_manager(enable : bool) -> void:
	var slm = options.get("_state_", "set_lod_manager")
	var root = get_tree().current_scene
	if slm == null:
		#find if lod manager is present in scene
		printd("Look for existing TreeManager")
		for p in utils.get_nodes_type(root, "Node", true):
			var obj = root.get_node(p)
			if obj.script and obj.get("id") and obj.id == "TreeManager":
				slm = p
				options.set("_state_", p, "set_lod_manager")
				printd("found TreeManager at %s" % p)
				break
		if enable == null:
			#just find if there is lod manager in the tree
			printd("end search for LodManager")
			return

	if not enable:
		if slm:
			var tm = root.get_node(slm)
			tm.enabled = false
		else:
			printd("set_lod_manager, attempt to disable notexisting tree manager")
		return #nothing to do here
		
	if slm == null:
		#create/add proper node
		printd("Load TreeManager")
		var tm_path = options.get("dev", "lod_manager_path", "res://scripts/TreeManager.tscn")
		var tm = ResourceLoader.load(tm_path)
		tm = tm.instance()
		root.add_child(tm)
		slm = root.get_path_to(tm)
		options.set("_state_", slm, "set_lod_manager")
	
	var tm = root.get_node(slm)
	if options.get("LOD", "lod_aspect_ratio"):
		tm.lod_aspect_ratio = options.get("LOD", "lod_aspect_ratio")
	tm.enabled = enable

func features_list(enabled_only : bool = true) -> void:
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
		{ opt = "debug", hint = "Running on a debug build (including the editor)" },
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
		{ opt = "updater", hint = "serve as data updater server for clients" }
		
	]

	if enabled_only:
		printd("OS:: print only enabled features")
	
	for f in features:
		if enabled_only:
			if OS.has_feature(f.opt):
				printd("OS::%s has %s" % [f.opt, OS.has_feature(f.opt)])
		else:
			printd("OS::%s has %s" % [f.opt, OS.has_feature(f.opt)])
	

func print_current_players() -> void:
	printd("gamestate players")
	print(gamestate.players)
	for p in gamestate.players.keys():
		printd("player %s" % gamestate.players[p])
		printd("obj at %s" % gamestate.players[p].obj.get_path())

func print_groups() -> void:
	#get_nodes_in_group("LODElement)
	printd("List of nodes in LODElement group")
	for obj in get_tree().get_nodes_in_group("LODElement"):
		print(obj.get_path())
	printd("List of nodes in wall group")
	for obj in get_tree().get_nodes_in_group("wall"):
		print(obj.get_path())
# 	for p in get_tree().call_group("LODElement", "get_path"):
# 		printd(p)
# 	printd("List of nodes in wall group")
# 	for p in get_tree().call_group("wall", "get_path"):
# 		printd(p)

func dir_contents(path : String = "res://") -> void:
	var dir = Directory.new()

	if dir.open(path) == OK:

		dir.list_dir_begin()
		var file_name = dir.get_next()

		while (file_name != ""):
			if dir.current_is_dir():
				print(dir.get_current_dir() + file_name + "/")
			else:
				print(dir.get_current_dir() + file_name)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func mouse_toggle() -> void:
	match Input.get_mouse_mode():
		Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			printd("set cursor to captured")
		Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			printd("set cursor to visible")
		_:
			print("mouse_toggle, do not know what to do, current mode %s" % Input.get_mouse_mode())
