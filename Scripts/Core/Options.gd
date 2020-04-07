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

signal user_settings_changed()

const opt_filter : Dictionary = {
		nocamera = true,
		network = true,
		input = true,
		username = true,
		gender = true,
		colors = true
	}

# scene we instance for each player
var player_scene : PackedScene = preload("res://Trees/Actors/LegacyPlayer/avatar_v2/player.tscn")

#############################
#    user avatar Options    #
#############################

var username : String = NameGenerator.get_name()
var gender : int = GENDERS.FEMALE
var pants_color : Color = Color(6.209207/256,17.062728/256,135.632141/256,1)
var shirt_color : Color = Color(0,233.62642/256,255/256,1)
var skin_color : Color = Color(186.98631/256,126.435381/256,47.515679/256,1)
var hair_color : Color = Color(0,0,0,1)
var shoes_color : Color = Color(0,0,0,1)
##############################

const config_path : String = "user://settings.cfg"
var config : ConfigFile = ConfigFile.new()

#############################
var fly_cameras : Array = [
	{ "label" : "Fly Camera", 	"path" : "res://assets/Player/flycamera/FlyCamera.tscn"},
]

#############################
# player instancing Options #
#############################

onready var player_data : Dictionary = {
	player_group = "player", #deprecated soon
	allow_unknown_options = true,
	instance = null,
	username = self.username,
	gender = self.gender,
	colors = {
		"pants" : pants_color, 
		"shirt" : shirt_color, 
		"skin" : skin_color, 
		"hair" : hair_color, 
		"shoes" : shoes_color
		},
	id = 0,
	options = {
		nocamera = false,
		input_processing = true,
		network = true,
		puppet = false,
		physics_scale = 0.1,
		IN_AIR_DELTA = 0.4
	}
	}


func _ready() -> void:
	print_debug("Options Singleton initializated")
	self.load_saved_config()

func player_data_set_pattern(type : String, opt : Dictionary = {}) -> Dictionary:
	
	var res : Dictionary = {}
	
	if opt!= {}:
		res = opt
	else:
		res = player_data.Options
	match type:
		"avatar_local":
			res["network"] = false
		"remote_puppet":
			res["puppet"] = true
			res["nocamera"] = true
		"server_bot":
			res["username"] = "Server Bot"
			res["nocamera"] = true
	return res
	
func get(category : String, prop : String = '', default=""):
	var res = config.get_value(category, prop, default)
	return res

func set(category : String, value, prop : String = '') -> void:
	config.set_value(category, prop, value)

func get_color(var color_name : String, var default_color : Color) -> Color:
	if not config.has_section_key('Pcolor', color_name + "R") or not config.has_section_key('Pcolor', color_name + "G") or not config.has_section_key('Pcolor', color_name + "B"):
		return default_color
	else:
		return Color8(config.get_value('Pcolor', color_name + "R"),config.get_value('Pcolor', color_name + "G"), config.get_value('Pcolor', color_name + "B"),255)
	
func update_player_data():
	player_data["username"] = username
	player_data["gender"] = gender
	player_data["colors"] = {
		"pants" : pants_color, 
		"shirt" : shirt_color, 
		"skin" : skin_color, 
		"hair" : hair_color, 
		"shoes" : shoes_color
		}

func load_saved_config()->void:
	var savefile : File = File.new()
	if not savefile.file_exists(config_path):
		config = ConfigFile.new()
	else:
		config.load(config_path)
		load_user_settings()
	update_player_data()
	load_graphics_settings()


func save() -> void:
	set("_state_", Lobby.local_id, "game_state_id")
	save_user_settings()
	config.save(config_path)
	update_player_data()

func has(category, prop = null) -> bool:
	var exists = false
	if config.has_section(category):
		exists = true
	if exists and prop != null:
		exists = config.has_section_key(category, prop)
	return exists

func get_tree_options(tree):
	var arr = get_nodes_type(tree, "Node")
	var Options
	for p in arr:
		var obj = tree.get_node(p)
		if obj.name == "Options":
			Options = obj
			break
	return Options

static func get_nodes_type(root : Node, type : String, recurent : bool = false):
	var nodes = get_nodes(root, recurent)
	var result = []
	for path in nodes:
		if root.get_node(path).get_class() == type :
			result.append(path)
	return result

static func get_nodes(root : Node , recurent : bool = false):
	var nodes = []
	var objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj.filename:
			if recurent:
				objects + obj.get_children()
		else:
			objects + obj.get_children()
		nodes.append(root.get_path_to(obj))
	return nodes

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

	pants_color = get_color("pants", Color8(49,4,5,255))
	shirt_color = get_color("shirt", Color8(87,235,192,255))
	skin_color = get_color("skin", Color8(150,112,86,255))
	hair_color = get_color("hair", Color8(0,0,0,255))
	shoes_color = get_color("shoes", Color8(78,158,187,255))

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


