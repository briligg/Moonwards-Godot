extends Node
""" 
This scrip manages the world loading and 
the scene information. 
"""
#TODO: Implement parallel and background loadings again.
signal scene_change(name)

#############################
#    load scene Options     #
#############################

var scenes : Dictionary = {
	loaded = null,
	default = "WorldV2",
	WorldV2 = {
		path = "res://Worlds/LegacyWorld/WorldV2.tscn"
	}
}



var level_loader : Object = preload("res://Core/World/LevelLoader.gd").new()
var current_world : Node = null
func set_current_world(new_world : Node) -> void:
	current_world = new_world
func change_scene(scene : String = scenes.default) -> void:
	var error
	if not scene in scenes:
		Log.hint(self, "change_scene", "No such scene registered in manager, attempting to load : %s" % scene)
		error = get_tree().change_scene(scene)
		if error == OK:
			emit_signal("scene_change", scene)
			return
		else:
			Log.error(self, "change_scene", "error changing scene, provided string is not a resource nor a scene")
			return
	else:
		Log.hint(self, "change_scene", "change_scene to %s" % scene)
		error = get_tree().change_scene(scenes[scene].path)
		if error == 0 :
			Log.hint(self, "change_scene", "changing scene okay(%s)" % Log.error_to_string(error))
			scenes.loaded = scene
			emit_signal("scene_change", scene)
			return
	Log.hint(self, "change_scene", "error changing scene %s" % Log.error_to_string(error))


func create_player(player : Dictionary) -> void:
	print("Creating a player, with id ", player.id)
	var world = get_tree().current_scene
	var spawn_pcount =  world.get_node("spawn_points").get_child_count()
	var spawn_pos = randi() % spawn_pcount
	var player_scene = player.instance
	if world.has_node(str("world/players/",player.id)):
		Log.hint(self, "create_player", str("player(", player.id, ") already added")) 
		print("Server says there's already a guy named", player.id, "what's going on?")
		return
	
	Log.hint(self, "create_player", "select spawn point(%s/%s)" % [spawn_pos, spawn_pcount])
	spawn_pos = world.get_node("spawn_points").get_child(spawn_pos).translation
#	player.flies = true # MUST CHANGE WHEN COLLISIONS ARE DONE
	if not is_instance_valid(player_scene):
		player.instance = Options.player_scene.instance()
		player_scene = player.instance
		player_apply_opt(player, player_scene)
	if player.id == Lobby.local_id:
		player_scene.SetRemotePlayer(false)
	else:
		player_scene.SetRemotePlayer(true)

	player_scene.SetPuppetColors(player.colors)
	player_scene.SetPuppetGender(player.gender)
	player_scene.SetUsername(player.username)

	player_scene.set_name(str(player.id)) # Use unique ID as node name
	player_scene.translation = spawn_pos
	player_scene.SetNetwork(true)

	if player.has("network"):
		player_scene.nonetwork = !player.network

	Log.hint(self, "create_player", "set_network will set(%s)" % player.id)
	if player.has("id"):
		Log.hint(self, "create_player", "create player set_network_master player id(%s) network id(%s)" % [Lobby.local_id, player.id])
		print("Setting player ", player_scene, " to be controlled by peer id: ", player.id, "local id is: ", Lobby.local_id)
		player_scene.set_network_master(player.id) #set unique id as master

	Log.hint(self, "create_player", "==create player(%s) %s; name(%s)" % [player.id, player, player.username])
	world.get_node("players").add_child(player_scene)
	Lobby.emit_signal("user_connected", player.username, player.id)

	# HACK: Does not belong here
	# TODO: Once joining a server, loading the world, etc is done, hide mainmenu
	MainMenu.hide()
	PauseMenu.hide()
	Hud.show()
	
func player_apply_opt(pdata : Dictionary, player : Spatial):
	pdata["instance"] = player
	#apply options given in register dictionary under avatar
	if pdata.has("options"):
		Log.hint(self, "player_apply_opt", "Applying options for avatar")
		for k in pdata.options:
			player.set(k, pdata.options[k])
		if pdata.options.has("input_processing"):
			 player.set_process_input(pdata.options["input_processing"])
	else:
		Log.error(self, "player_apply_opt", "invalid player_data dictionary")
		pdata.options = Options.player_data.options
		player_apply_opt(pdata, player)
"""
This is legacy code that needs checking

func loading_done(var error : int) -> void:
	if error == OK or error == ERR_FILE_EOF:
		Log.hint(self, "loading_done", "changing scene okay(%s)" % level_loader.error)
		emit_signal("loading_done")
	else:
		Log.hint(self, "loading_done", "error changing scene %s" % level_loader.error)
		Log.hint(self, "loading_done", "Error! " + Log.error_to_string(error))

func load_level(var resource) -> void: #Resource is variant
	# Check if the resource is valid before switching to loading screen.
	if resource is String:
		if Options.scenes.has(resource):
			resource = Options.scenes[resource].path
		if not ResourceLoader.exists(resource):
			emit_signal("loading_error", "File does not exist: " + resource)
			return
	elif resource is PackedScene:
		if not resource.can_instance():
			emit_signal("loading_error", "Can not instance resource.")
			return

	level_loader.start_loading(resource)
	yield(self, "loading_done")

	world = level_loader.new_scene.instance()
	get_tree().get_root().add_child(world)
	get_tree().current_scene = world
	emit_signal("scene_change")
	
	"""
