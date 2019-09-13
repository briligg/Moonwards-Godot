extends Node
var id : String = "options.gd"
var debug : bool = true

var Updater : Node 
var scripts : Dictionary = {
	Updater = preload("res://core/update/scripts/Updater.gd")
}
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
#       Other options      #
############################
var options : Dictionary = {
}

#############################
#    user avatar options    #
#############################
signal user_settings_changed

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

var username : String = namelist.get_name()
var gender : int = GENDERS.FEMALE
var pants_color : Color = Color(6.209207/256,17.062728/256,135.632141/256,1)
var shirt_color : Color = Color(0,233.62642/256,255/256,1)
var skin_color : Color = Color(186.98631/256,126.435381/256,47.515679/256,1)
var hair_color : Color = Color(0,0,0,1)
var shoes_color : Color = Color(0,0,0,1)
var savefile_json

#FIXME Writing and reading should be done with a ConfigFile instead of writing a dictionary using File.
var OptionsFile : String = "user://gameoptions.save"
var User_file : String = "user://settings.save"

#############################
#       debug function      #
#############################
func printd(s):
	logg.print_fd(id, s)

#############################
# load scene options
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
	{ "label" : "Fly Camera", 	"path" : "res://assets/Player/flycamera/player.tscn"},
	{ "label" : "Media Camera", "path" : "res://assets/Player/flycamera_ac/player.tscn" }
]

#############################
# player instancing options #
#############################
var player_opt : Dictionary = {
	player_group = "player",
	opt_allow_unknown = true,
	PlayerGroup = "PlayerGroup", #local player group
	opt_filter = {
		debug = true,
		nocamera = true,
		username = true,
		gender = true,
		colors = true
	},
	avatar = {
		debug = debug,
		nocamera = false,
		input_processing = true,
		network = true,
		puppet = false,
		physics_scale = 0.1,
		IN_AIR_DELTA = 0.4
	},
	avatar_local = {
		debug = debug,
		nocamera = false,
		input_processing = true,
		network = false,
		puppet = false,
		physics_scale = 0.1,
	},
	puppet = {
		debug = debug,
		nocamera = true,
		input_processing = false,
		network = true,
		puppet = true
	},
	server_bot = {
		debug = debug,
		nocamera = true,
		network = true,
		puppet = false,
		username = "Server Bot"
	}
}


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
				if not k in filter:
					printd("player_filter_opt, default allow unknown option %s %s" % [k, opt[k]])

	if not player_opt.has(type):
		printd("player_filter_opt, unknown player opt type %s" % type)
	else:
		var def_opt : Array = player_opt[type]
		for k in def_opt:
			res[k] = def_opt[k]
	return res



func _ready() -> void:
	Updater = scripts.Updater.new()
	Updater.set_root_tree(get_tree())
# 	print("debug set FPS to 3")
# 	Engine.target_fps = 3
	printd("load options and settings")
	self.load()
	set_defaults()
	LoadUserSettings()

func load()->void:
	var savefile : File = File.new()
	if not savefile.file_exists(OptionsFile):
		printd("Nothing was saved before")
	else:
		savefile.open(OptionsFile, File.READ)
		var content = str2var(savefile.get_as_text())
		savefile.close()
		if content:
			if content.has("_state_"):
				content.erase("_state_")
			options = content
		printd("options loaded from %s" % OptionsFile)

func save() -> void:
	var savefile : File = File.new()
	savefile.open(OptionsFile, File.WRITE)
	set("_state_", gamestate.local_id, "game_state_id")
	savefile.store_line(var2str(options))
	savefile.close()
	printd("options saved to %s" % OptionsFile)

func get(category : String, prop = null, default=null) -> bool:
	var res 
	if options.has(category):
		if prop and options[category].has(prop):
			res = options[category][prop]
		elif prop:
			pass
		else:
			res = options[category]
	if res == null and default != null:
		if prop:
			if not options.has(category):
				options[category] = {}
			options[category][prop] = default
		else:
			options[category] = default
		res = default
	printd("get: %s::%s==%s" % [category, prop, res])
	return res

func set(category, value, prop = null):
	printd("options set %s::%s %s" % [category, prop, value])
	if prop == null:
		options[category] = value
	else:
		if not options.has(category):
			options[category] = {}
		options[category][prop] = value

func del_state(prop):
	printd("options del_stat ::%s" % prop)
	if options.has("_state_"):
		if options["_state_"].has(prop):
			options["_state_"].erase(prop)

func has(category, prop = null):
	var exists = false
	if options.has(category):
		exists = true
	if exists and prop != null:
		exists = options[category].has(prop)
	return exists

func get_tree_options(tree):
	var arr = utils.get_nodes_type(tree, "Node")
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
	#get options under Node-Options
	#
	var Options = get_tree_options(root)
	if Options:
		var obj = Options.get_node(opt)
		if obj:
			res = true
	return res

func LoadUserSettings():
	var savefile = File.new()
	if not savefile.file_exists(User_file):
		SaveUserSettings()

	savefile.open(User_file, File.READ)
	print(savefile.get_as_text())
	savefile_json = parse_json(savefile.get_as_text())
	savefile.close()
	gender = SafeGetSetting("gender", GENDERS.FEMALE)
	username = SafeGetSetting("username", "Player Name")

	pants_color = SafeGetColor("pants", Color8(49,4,5,255))
	shirt_color = SafeGetColor("shirt", Color8(87,235,192,255))
	skin_color = SafeGetColor("skin", Color8(150,112,86,255))
	hair_color = SafeGetColor("hair", Color8(0,0,0,255))
	shoes_color = SafeGetColor("shoes", Color8(78,158,187,255))

func SafeGetColor(var color_name, var default_color) -> Color:
	if not savefile_json.has(color_name + "R") or not savefile_json.has(color_name + "G") or not savefile_json.has(color_name + "B"):
		return default_color
	else:
		return Color8(savefile_json[color_name + "R"],savefile_json[color_name + "G"],savefile_json[color_name + "B"],255)

func SafeGetSetting(var setting_name, var default_value):

	if not savefile_json.has(setting_name):
		return default_value
	else:
		return savefile_json[setting_name]

func SaveUserSettings():
	var savefile = File.new()
	savefile.open(User_file, File.WRITE)
	var save_dict = {

		"username" : username,
		"gender" : gender,

		"pantsR" : pants_color.r*255, # Vector3 is not supported by JSON
		"pantsG" : pants_color.g*255,
		"pantsB" : pants_color.b*255,

		"shirtR" : shirt_color.r*255,
		"shirtG" : shirt_color.g*255,
		"shirtB" : shirt_color.b*255,

		"skinR" : skin_color.r*255,
		"skinG" : skin_color.g*255,
		"skinB" : skin_color.b*255,

		"hairR" : hair_color.r*255,
		"hairG" : hair_color.g*255,
		"hairB" : hair_color.b*255,

		"shoesR" : shoes_color.r*255,
		"shoesG" : shoes_color.g*255,
		"shoesB" : shoes_color.b*255,

		}
	savefile.store_line(to_json(save_dict))
	savefile.close()
	emit_signal("user_settings_changed")
