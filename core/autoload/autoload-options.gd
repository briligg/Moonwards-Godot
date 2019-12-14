extends Node

enum SLOTS{
	PANTS,
	SHIRT,
	SKIN,
	HAIR,
	SHOES
}

enum GENDERS{
	FEMALE,
	MALE
}
const id : String = "Options.gd"

var Debugger : bool = true

# scene for players, node name wich serves an indicator
var scene_id : String= "scene_id_30160"

# scene we instance for each player
var player_scene : PackedScene = preload("res://assets/Player/avatar_v2/player.tscn")

# Join server host
# var join_server_host = "127.0.0.1"
# 
# var join_server_host = "moonwards.hopto.org"
var join_server_host : String = "mainhabs.moonwards.com"


############################
#       Other Options      #
############################
var Options : Dictionary = {
}

#############################
#    user avatar Options    #
#############################
signal user_settings_changed


var username : String = Utilities.get_name()
var gender : int = GENDERS.FEMALE
var pants_color : Color = Color(6.209207/256,17.062728/256,135.632141/256,1)
var shirt_color : Color = Color(0,233.62642/256,255/256,1)
var skin_color : Color = Color(186.98631/256,126.435381/256,47.515679/256,1)
var hair_color : Color = Color(0,0,0,1)
var shoes_color : Color = Color(0,0,0,1)
var savefile_json

const Config_File : String = "user://settings.cfg"
var config : ConfigFile = ConfigFile.new()
#############################
# load scene Options
var scenes : Dictionary = {
	loaded = null,
	default = "WorldTest",
#	default_run_scene = "WorldTest2",
# 	default_run_scene = "WorldTest",
	default_run_scene = "WorldV2",
	default_singleplayer_scene = "WorldV2",
	default_multiplayer_scene = "WorldV2",
	default_multiplayer_headless_scene = "WorldServer",
	default_multiplayer_join_server = "WorldV2",
#	default_multiplayer_join_server = "WorldTest",
	WorldV2 = {
		path = "res://WorldV2.tscn"
	},
	WorldTest = {
		path = "res://_tests/scene_mp/multiplayer_test_scene.tscn"
	},
	WorldTest2 = {
		path = "res://_tests/scene_mp/multiplayer_test_scene2.tscn"
	},
	WorldServer = {
		path = "res://WorldServer.tscn"
	}
}

var fly_cameras : Array = [
	{ "label" : "Fly Camera", 	"path" : "res://assets/Player/flycamera/FlyCamera.tscn"},
	{ "label" : "Media Camera", "path" : "res://assets/Player/MediaModeCamera/media_mode_camera.tscn" }
]

#############################
# player instancing Options #
#############################
var player_opt : Dictionary = {
	player_group = "player",
	opt_allow_unknown = true,
	PlayerGroup = "PlayerGroup", #local player group
	opt_filter = {
		Debugger = true,
		nocamera = true,
		username = true,
		gender = true,
		colors = true
	},
	avatar = {
		Debugger = Debugger,
		nocamera = false,
		input_processing = true,
		network = true,
		puppet = false,
		physics_scale = 0.1,
		IN_AIR_DELTA = 0.4
	},
	avatar_local = {
		Debugger = Debugger,
		nocamera = false,
		input_processing = true,
		network = false,
		puppet = false,
		physics_scale = 0.1,
	},
	puppet = {
		Debugger = Debugger,
		nocamera = true,
		input_processing = false,
		network = true,
		puppet = true
	},
	server_bot = {
		Debugger = Debugger,
		nocamera = true,
		network = true,
		puppet = false,
		username = "Server Bot"
	}
}



func _ready() -> void:
# 	print("Debugger set FPS to 3")
# 	Engine.target_fps = 3
	printd("_ready","load Options and settings")
	self.load()
	set_defaults()
	load_graphics_settings()

#############################
#       Debugger function      #
#############################
func printd(function_name, s):
	Log.hint(self, function_name, s)



#############################
# functions and variable to sort
func set_defaults() -> void:
	# set some default values, probably improve that
	get("dev", "enable_areas_lod", true)
	get("dev", "enable_collision_shapes", true)
	get("dev", "3FPSlimit", true)
	get("dev", "3FPSlimit_value", 30)
	get("dev", "hide_meshes_random", false)
	get("dev", "decimate_percent", 90)
	get("dev", "TreeManager", true)
	get("LOD", "lod_aspect_ratio", 150)
	# get("dev", "lod_manager_path", "res://scripts/TreeManager.tscn")

func player_opt(type, opt : Dictionary = {}) -> Dictionary:
	var res : Dictionary= {}
	var filter : Dictionary = player_opt.opt_filter
	var filter_id : int = "opt_filter_%s" % type
	if player_opt.has(filter_id):
		filter = player_opt[filter_id]

	var allow_unknown : bool = player_opt.opt_allow_unknown
	if opt != {}:
		for k in opt:
			if filter.has(k) and filter[k] or allow_unknown:
				res[k] = opt[k]
#				if not k in filter:
#					printd("player_filter_opt, default allow unknown option %s %s" % [k, opt[k]])

#	if not player_opt.has(type):
#		printd("player_filter_opt, unknown player opt type %s" % type)
	if player_opt.has(type):
		var def_opt : Array = player_opt[type]
		for k in def_opt:
			res[k] = def_opt[k]
	return res





func load()->void:
	var savefile : File = File.new()
	if not savefile.file_exists(Config_File):
		printd("load", "Nothing was saved before")
		config = ConfigFile.new()
	else:
		config.load(Config_File)
		load_user_settings()
		printd("load", "Options loaded from %s" % Config_File)
		

func save() -> void:
	set("_state_", GameState.local_id, "game_state_id")
	save_user_settings()
	config.save(Config_File)
	printd("save","Options saved to %s" % Config_File)

func get(category : String, prop : String = '', default=""):
	var res = config.get_value(category, prop, default)
	return res

func set(category : String, value, prop : String = '') -> void:
	config.set_value(category, prop, value)


func del_state(prop):
	#printd("Options del_stat ::%s" % prop)
	if Options.has("_state_"):
		if Options["_state_"].has(prop):
			Options["_state_"].erase(prop)

func has(category, prop = null) -> bool:
	var exists = false
	if config.has_section(category):
		exists = true
	if exists and prop != null:
		exists = config.has_section_key(category, prop)
	return exists

func get_tree_options(tree):
	var arr = Utilities.get_nodes_type(tree, "Node")
	var Options
	for p in arr:
		var obj = tree.get_node(p)
		if obj.name == "Options":
			Options = obj
			break
	return Options

func get_tree_opt(opt):
	var res = false
	var root = get_tree().current_scene
	if root == null:
		return res
	#get Options under Node-Options
	#
	var Options = get_tree_options(root)
	if Options:
		var obj = Options.get_node(opt)
		if obj:
			res = true
	return res

func load_user_settings() -> void:
	gender = get('player', "gender", GENDERS.FEMALE)
	username = get('player', "username", "Player Name")

	pants_color = safe_get_color("pants", Color8(49,4,5,255))
	shirt_color = safe_get_color("shirt", Color8(87,235,192,255))
	skin_color = safe_get_color("skin", Color8(150,112,86,255))
	hair_color = safe_get_color("hair", Color8(0,0,0,255))
	shoes_color = safe_get_color("shoes", Color8(78,158,187,255))

func safe_get_color(var color_name : String, var default_color : Color) -> Color:
	if not config.has_section_key('Pcolor', color_name + "R") or not config.has_section_key('Pcolor', color_name + "G") or not config.has_section_key('Pcolor', color_name + "B"):
		return default_color
	else:
		return Color8(config.get_value('Pcolor', color_name + "R"),config.get_value('Pcolor', color_name + "G"), config.get_value('Pcolor', color_name + "B"),255)


func save_user_settings() -> void:
	set('player', username, "username")
	set('player', gender, "gender")
	
	set('Pcolor', pants_color.r*255, "pantsR")
	set('Pcolor', pants_color.g*255, "pantsG")
	set('Pcolor', pants_color.b*255, "pantsB")

	set('Pcolor', shirt_color.r*255, "shirtR")
	set('Pcolor', shirt_color.g*255, "shirtG")
	set('Pcolor', shirt_color.b*255, "shirtB")

	set('Pcolor', skin_color.r*255, "skinR")
	set('Pcolor', skin_color.g*255, "skinG")
	set('Pcolor', skin_color.b*255, "skinB")

	set('Pcolor', hair_color.r*255, "hairR")
	set('Pcolor', hair_color.g*255, "hairG")
	set('Pcolor', hair_color.b*255, "hairB")

	set('Pcolor', shoes_color.r*255, "shoesR")
	set('Pcolor', shoes_color.g*255, "shoesG")
	set('Pcolor', shoes_color.b*255, "shoesB")

	emit_signal("user_settings_changed")

func load_graphics_settings() -> void:
	var resolutions : Vector2 = Vector2()
	var mode : String = get("resolution", "mode", "Windowed")
	
	resolutions.x = get("resolution", "width", 1024)
	resolutions.y = get("resolution", "height", 700)
	
	match mode:
		"Windowed":
			OS.window_borderless = false
			OS.window_fullscreen = false
			if OS.get_window_safe_area().size.x >= resolutions.x or OS.get_window_safe_area().size.y >= resolutions.y:
				OS.window_size = resolutions
			else:
				OS.window_size = OS.get_window_safe_area().size
		"Borderless":
			OS.window_borderless = true
			OS.window_fullscreen = false
		"Fullscreen":
			OS.window_borderless = false
			OS.window_fullscreen = true
			
	get_tree().get_root().size = resolutions