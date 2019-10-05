extends Node

enum MODE {
	TOGGLE = 0,
	CONNECT = 1,
	DISCONNECT = 2
	}

#global signals
signal log_gamestate(msg)
# network user related
signal user_join #emit when user is fully registered
signal user_leave #emit on leave of registered user
signal user_name_disconnected(name) #emit when user is joined, for chat
signal user_name_connected(name) #emit when user is disconnected, for chat
signal user_msg(id, msg) #emit message of id user
signal player_id(id) #emit id of player after establishing a connection
#network server
signal server_up
#network client
signal server_connected
#network general
signal server_select # show dialog to connect to a server or create a server
signal network_error(message)
signal network_log(message) #emmit on change in server status, client status - conenction, establishing connection etc

#scenes
signal scene_change
signal scene_change_name(name)
signal scene_change_error(msg)
signal loading_progress(percentage)
signal loading_done
signal loading_error(msg)
signal player_scene #emit when a scene for players is detected

# Signals to let lobby GUI know what's going on
signal connection_failed
signal connection_succeeded
signal game_ended
signal game_error(what)

# Default game port
const DEFAULT_PORT : int = 10567

# Max number of players
const MAX_PEERS : int = 12

# remote players in id:player_data format
var players : Dictionary = {}
var network_id : int 
var local_id : int = 0
var chat_ui_resource : PackedScene = preload("res://assets/UI/chat/ChatUI.tscn")
var chat_ui = null

#
# hold last error message
var error_msg : String = "Ok"
# indicate server role, mutial to client role
var RoleServer : bool = false
#indicate client role, mutual to server role
var RoleClient : bool = false
var RoleNoNetwork : bool = false

var _queue_attach : Dictionary = {}
var _queue_attach_on_tree_change_lock : bool = false #emits tree_change events on adding node, prevent stack overflow
var _queue_attach_on_tree_change_prev_scene : String

var server : Dictionary = {
	host = "localhost",
	ip = "127.0.0.1",
	connection = null,
	up = false
}
var client : Dictionary = {
	host = "localhost",
	ip = "127.0.0.1",
	port = DEFAULT_PORT,
	connection = null,
	up = false
}

var NetworkUP : bool = false
var PlayerSceneUP : bool = false
#signal player(node_path) #emit when local player instanced to scene
#################
# util functions

var level_loader : Object = preload("res://scripts/LevelLoader.gd").new()
var world : Node = null
var debug_id : String = "gamestate"
func _ready():
	#get_tree().connect("network_peer_connected", self, "_player_connected")

	local_id = 0

	bind_signal("network_log", "", self, self, MODE.TOGGLE)
	bind_signal("log_gamestate", "", self, self, MODE.TOGGLE)
	bind_signal("player_scene", "", self, self, MODE.TOGGLE)
	bind_signal("player_id", "", self, self, MODE.TOGGLE)
	
	queue_tree_signal(options.scene_id, "player_scene", true)
	log_all_signals()
	
	connect("player_scene", self, "player_scene")
	net_tree_connect()

func bind_signal(signal_name : String, method : String, obj : Object, obj2 : Object, mode : int = 0) -> void:
	if method == "":
		method = str("_on_", signal_name)
		
	if mode == MODE.TOGGLE:  
		if obj.is_connected(signal_name, obj2, method):
			obj.disconnect(signal_name, obj2, method)
			emit_signal("log_gamestate", "disconnect signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method)
		else:
			obj.connect(signal_name, obj2, method)
			emit_signal("log_gamestate", "connect signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method)
	
	elif mode == MODE.CONNECT : #connect
		if not obj.is_connected(signal_name, obj2, method):
			obj.connect(signal_name, obj2, method)
		else:
			emit_signal("log_gamestate", "tried to connect already connected signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method)
	
	elif mode == MODE.DISCONNECT : #disconnect
		if obj.is_connected(signal_name, obj2, method):
			obj.disconnect(signal_name, obj2, method)
			emit_signal("log_gamestate", "disconnect signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method)
		else:
			emit_signal("log_gamestate", "tried to disconnect a disconnected signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method)


#################
#Track scene changes and add nodes or emit signals functions


func queue_attach(path : String, node, permanent : bool = false) -> void: #node is variant
	emit_signal("log_gamestate", str("attach queue(permanent: ", str(permanent),"): ", path, "(", node, ")")) 
	var packedscene
	if node is String:
		packedscene = ResourceLoader.load(node)
		emit_signal("log_gamestate", str("loading resource in queue_attach(", path, ", ", node, ", ", permanent,")"))
		if not packedscene:
			emit_signal("log_gamestate", str("error loading resource in queue_attach(", path, ", ", node, ", ", permanent,")"))
			return
	if not packedscene:
		packedscene = node
	_queue_attach[path] = {
			path = path,
			permanent = permanent,
			node = node,
			packedscene = packedscene
		}
	print("+++", _queue_attach[path].packedscene)
	bind_signal("tree_changed","_on_queue_attach_on_tree_change", get_tree(), self, MODE.CONNECT) 

func queue_tree_signal(path : String, signal_name : String, permanent : bool = false) -> void:
	emit_signal("log_gamestate", "signal queue(permanent %s): %s(%s)" % [permanent, path, signal_name])
	_queue_attach[path] = {
			path = path,
			permanent = permanent,
			signal = signal_name,
		}
	bind_signal("tree_changed", "_on_queue_attach_on_tree_change", get_tree(), self, MODE.CONNECT)


#################
# general network functions

func net_tree_connect(bind : bool = true) -> void:
	var tree = get_tree()
	
	var signals = [
		["connected_to_server", "_on_net_server_connected", tree],
		["server_disconnected", "_on_net_server_disconnected", tree],
		["connection_failed", "_on_net_connection_fail", tree],
		["network_peer_connected", "_on_net_client_connected", tree],
		["network_peer_disconnected", "_on_net_client_disconnected", tree],
		["server_up", "_on_net_server_up", self]
	]
	for sg in signals:
		printd(str("net_tree_connect", sg[0], " -> " , sg[1]))
		if bind:
			bind_signal(sg[0], sg[1], sg[2], self, MODE.CONNECT)
		else:
			bind_signal(sg[0], sg[1], sg[2], self, MODE.DISCONNECT)



#################
#Server functions


func server_set_mode(host : String = "localhost"):
	if RoleClient :
		emit_signal("network_error", "Currently in client mode")
		return
	if RoleServer :
		emit_signal("network_error", "Already in server mode")
		return
	if RoleNoNetwork :
		emit_signal("network_error", "No network mode enabled")
		return
	
	RoleServer = true
	
	server.host = host
	server.ip = IP.resolve_hostname(host, 1) #TYPE_IPV4 - ipv4 adresses only
	if not server.ip.is_valid_ip_address():
		var msg = "fail to resolve host(%s) to ip adress" % server.host
		emit_signal("network_log", msg)
		emit_signal("network_error", msg)
		RoleServer = false
		return
	emit_signal("network_log", "prepare to listen on %s:%s" % [server.ip,DEFAULT_PORT])
	server.connection = net_getsocket()
	server.connection.set_bind_ip(server.ip)
	var error : int = server.connection.create_server(DEFAULT_PORT, MAX_PEERS)
	if error == 0:
		get_tree().set_network_peer(server.connection)
		emit_signal("network_log", "server up on %s:%s" % [server.ip,DEFAULT_PORT])
		server.up = true
		bind_signal("tree_changed", "_on_server_tree_changed", get_tree(), self, MODE.CONNECT)
		emit_signal("server_up")
		
		bind_signal("peer_disconnected", "_on_server_user_disconnected", server.connection, self, MODE.CONNECT) 
		bind_signal("peer_connected", "_on_server_user_connected", server.connection, self, MODE.CONNECT) 
		
		bind_signal("network_peer_connected", "_on_server_tree_user_connected", get_tree(), self, MODE.CONNECT)
		bind_signal("network_peer_disconnected", "_on_server_tree_user_disconnected", get_tree(), self, MODE.CONNECT)

		emit_signal("log_gamestate", "network server id %s" % server.connection.get_unique_id())
		network_id = server.connection.get_unique_id()
		emit_signal("player_id", network_id)
	else:
		emit_signal("network_log", "server error %s" % error)
		emit_signal("network_error", "failed to bring server up, error %s" % error)
		RoleServer = false
# 		emit_signal("connection_failed")

################
#Client functions




func client_server_connect(host : String, port : int = DEFAULT_PORT):
	if RoleClient :
		emit_signal("network_error", "Already in client mode")
		return
	if RoleServer :
		emit_signal("network_error", "Currently in server mode")
		return
	if RoleNoNetwork :
		emit_signal("network_error", "No network mode enabled")
		return
	
	RoleClient = true
	
	client.host = host
	client.ip = IP.resolve_hostname(host, 1) #TYPE_IPV4 - ipv4 adresses only
	if not client.ip.is_valid_ip_address():
		var msg = "fail to resolve host(%s) to ip adress" % server.host
		emit_signal("network_log", msg)
		emit_signal("network_error", msg)
		RoleClient = false
		return
	client.port = port
	emit_signal("network_log", "connect to server %s(%s):%s" % [player_get("host"), player_get("ip"), player_get("port")])
	
	bind_signal("connection_failed", '', get_tree(), self, MODE.CONNECT)
	bind_signal("connected_to_server", "", get_tree(), self, MODE.CONNECT)
	client.connection = net_getsocket()
	client.connection.create_client(player_get("ip"), player_get("port"))
	emit_signal("gamestate_log", "network id %s" % client.connection.get_unique_id())
	network_id = client.connection.get_unique_id()
	emit_signal("player_id", network_id)
	get_tree().set_network_peer(client.connection)


################
# Scene functions
func change_scene(scene : String) -> void:
	var scenes = options.scenes
	if not scene in scenes:
		emit_signal("scene_change_error", "No such scene %s" % scene)
		emit_signal("log_gamestate", "No such scene %s" % scene)
		return
	
	emit_signal("log_gamestate", "change_scene to %s" % scene)
	var error = get_tree().change_scene(scenes[scene].path)
	if error == 0 :
		emit_signal("gamestate_log", "changing scene okay(%s)" % error)
		scenes.loaded = scene
		emit_signal("scene_change")
		emit_signal("scene_change_name", scene)
	else:
		emit_signal("log_gamestate", "error changing scene %s" % error)



func is_player_scene() -> bool:
	var result : bool = false
	if get_tree() and get_tree().current_scene:
		if get_tree().current_scene.has_node(options.scene_id):
			result = true
	return result

################
# Player functions
func player_apply_opt(pdata : Dictionary, player : Spatial, id : int):
	#apply options, given in register dictionary under ::options
	if pdata.has("options"):
		printd("player_apply_opt to %s with %s" % [id, pdata])
		var opt = pdata.options
		printd("create_player Apply options to id %s : %s" % [id, opt])
		for k in opt:
			player.set(k, opt[k])
		if opt.has("input_processing") and opt["input_processing"] == false:
			printd("disable input for player avatar %s" % id)
			player.set_process_input(false)

func player_register(pdata : Dictionary, localplayer : bool = false, opt_id : String = "avatar") -> void:
	var id : int = 0
	if localplayer:
		pdata["options"] = options.player_opt(opt_id, pdata) #merge name with rest of options for Avatar
		if network_id:
			id = network_id
		else:
			id = local_id
	elif pdata.has("id"):
		id = pdata.id
	else:
		emit_signal("log_gamestate", "player data should have id or be a local")
		return
	
	emit_signal("log_gamestate", "registered player(", str(id), "): ", str(pdata))
	var player = {}
	player["data"] = pdata
	player["obj"] = options.player_scene.instance()
	player_apply_opt(player["data"], player["obj"], id)
# 	player["localplayer"] = localplayer
	if localplayer:
		if network_id :
			player["id"] = id
		players[id] = player
	else:
		player["id"] = id
		players[id] = player
	
	if is_player_scene():
		create_player(id)

#local player recieved network id

remote func register_client(id : int, pdata : Dictionary) -> void:
	printd("remote register_client, local_id(%s): %s %s" % [local_id, id, pdata])
	if id == local_id:
		printd("Local player, skipp")
		return
	if players.has(id):
		printd("register client(%s): already exists(%s)" % [local_id, id])
		return
	printd("register_client: id(%s), data: %s" % [id, pdata])
	pdata["id"] = id
	if pdata.has("options"):
		pdata["options"] = options.player_opt("puppet", pdata["options"])
	else:
		pdata["options"] = options.player_opt("puppet")

	player_register(pdata)
	if RoleServer:
		#sync existing players
		rpc("register_client", id, pdata)
		for p in players:
			printd("**** %s" % players[p])
			var pid = players[p].id
			if pid != id:
				rpc_id(id, "register_client", pid, players[p].data)

remote func unregister_client(id : int) -> void:
	emit_signal("log_gamestate", "unregister client (%s)" % id)
	if players.has(id):
		emit_signal("user_name_disconnected", "%s" % player_get("name", id))
		if players[id].obj:
			players[id].obj.queue_free()
		players.erase(id)
	if RoleServer:
		#sync existing players
		for p in players:
			print("**** %s" % players[p])
			var pid = players[p].id
			if pid != local_id:
				rpc_id(pid, "unregister_client", id)


func player_get(prop, id : int = -1): #prop and result are variants
	if id == -1:
		id = local_id
	var error : bool = false
	var result = null
	if not players.has(id):
		return result
	if players[id].data.has(prop):
		result = players[id].data[prop]
	elif players[id].has(prop):
		result = players[id][prop]
	elif client.has(prop):
		result = client[prop]
	else:
		match prop:
			"name" :
				result = players[id].obj.username
			_:
				error = true
	if error:
		emit_signal("gamestate_log", "error: player data, no property(%s)" % prop)
	return result

#remap local user for its network id, when he gets it
func player_remap_id(old_id : int, new_id : int) -> void:
	if players.has(old_id):
		var player = players[old_id]
		players.erase(old_id)
		players[new_id] = player
		player["id"] = new_id
		emit_signal("log_gamestate", "remap player old_id(%s), new_id(%s)" % [old_id, new_id])
		if player.has("path"):
			var node = player.obj
			node.name = "%s" % new_id
			var world = get_tree().current_scene
			emit_signal("log_gamestate", "remap player, old path %s to %s" % [player.path, world.get_path_to(node)])
			player["path"] = world.get_path_to(node)
			node.set_network_master(new_id)

func create_player(id : int) -> void:
	var world = get_tree().current_scene
	if players[id].has("world") and players[id]["world"] == str(world):
		emit_signal("log_gamestate", "player(%s) already added, %s" % [id, players[id]])
		return
	var spawn_pcount =  world.get_node("spawn_points").get_child_count()
	var spawn_pos = randi() % spawn_pcount
	emit_signal("log_gamestate", "select spawn point(%s/%s)" % [spawn_pos, spawn_pcount])
	spawn_pos = world.get_node("spawn_points").get_child(spawn_pos).translation
	var player = players[id].obj
#	player.flies = true # MUST CHANGE WHEN COLLISIONS ARE DONE
	player.set_name(str(id)) # Use unique ID as node name
	player.translation=spawn_pos
	
	if players[id].data.has("network"):
		player.nonetwork = !players[id].data.network
	
	printd("cp set_network will set(%s) %s %s" % [players[id].has("id") and not player.nonetwork, players[id].has("id"), not player.nonetwork])
	if players[id].has("id") and not player.nonetwork:
		printd("create player set_network_master player id(%s) network id(%s)" % [id, players[id].id])
		player.set_network_master(players[id].id) #set unique id as master
	
	emit_signal("log_gamestate", "==create player(%s) %s; name(%s)" % [id, players[id], players[id].data.username])
	world.get_node("players").add_child(player)
	players[id]["world"] = "%s" % world
	players[id]["path"] = world.get_path_to(player)
	emit_signal("user_name_connected", player_get("name", id))

#set current camera to local player
func player_local_camera(activate : bool = true) -> void:
	if players.has(local_id):
		players[local_id].obj.nocamera = !activate

func player_noinput(enable : bool = false) -> void:
	if players.has(local_id):
		players[local_id].obj.input_processing = enable

# Callback from SceneTree, only for clients (not server)

# Lobby management functions

func end_game() -> void:
	if (has_node("/root/world")): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

#################
# debug functions


func printd(s : String) -> void:
	logg.print_filtered_message(debug_id, s)

func log_all_signals() -> void:
	var sg_ignore = ["_on_gamestate_log"]
	var sg_added = ""
	for sg in get_signal_list():
		if sg.name in sg_ignore:
			continue
		#printd("log all signals connect %s" % sg)
		sg_added = "%s(%s) %s" % [sg.name, sg.args.size(), sg_added]
		connect(sg.name, self, "log_all_signals_print_%s" % (sg.args.size()+1), ["%s" % sg.name])
	printd("log_all_signals: %s" % sg_added)
		
func log_all_signals_print_1(signal_name : String):
	printd(str("==========signal0 ", signal_name," ================"))
func log_all_signals_print_2(a1 : int, signal_name : String):
	printd(str("==========signal1 ", signal_name," ================"))
	printd(str(a1))
func log_all_signals_print_3(a1 : int, a2 : int, signal_name : String):
	printd(str("==========signal2 ", signal_name," ================"))
	printd(str(a1, a2))

#################
# New UI functions



func loading_done(var error : int) -> void:
	if error == OK or error == ERR_FILE_EOF:
		emit_signal("log_gamestate", "changing scene okay(%s)" % level_loader.error)
		emit_signal("loading_done")
	else:
		emit_signal("log_gamestate", "error changing scene %s" % level_loader.error)
		emit_signal("loading_error", "Error! " + str(error))

func load_level(var resource) -> void: #Resource is variant
	# Check if the resource is valid before switching to loading screen.
	if resource is String:
		if options.scenes.has(resource):
			resource = options.scenes[resource].path
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

#################
# avatar network/scene functions

#network and player scene state


func net_up() -> void: 
	if PlayerSceneUP:
		printd("------net_up---enable networking in instanced players--------")
	else:
		printd("------net_up---do nothing--------")

func net_down() -> void:
	if PlayerSceneUP:
		printd("------net_down---players disable netwokring--------")
	else:
		printd("------net_down---players do nothing--------")

func net_client(id : int, connected : bool) -> void:
	if connected:
		printd("------net_client(%s)---make stub for %s---------" % [connected, id])
	else:
		printd("------net_client(%s)---disconnect client %s-----" % [connected, id])

func player_scene() -> void:
	printd("------instance avatars with networking(%s) - players count %s" % [NetworkUP, players.size()])
	PlayerSceneUP = true

func add_chat_ui() -> void:
	if not is_instance_valid(chat_ui):
		chat_ui = chat_ui_resource.instance()
		get_tree().root.add_child(chat_ui)
		
func _on_queue_attach_on_tree_change() -> void:
	if _queue_attach_on_tree_change_lock:
		return
	if get_tree():
		if _queue_attach_on_tree_change_prev_scene != str(get_tree().current_scene):
			_queue_attach_on_tree_change_prev_scene = str(get_tree().current_scene)
			emit_signal("log_gamestate", "qatc: Scene changed %s" % _queue_attach_on_tree_change_prev_scene)
			for p in _queue_attach:
				if _queue_attach[p].has("node"):
					emit_signal("gamestate_log", "qatc: node %s(%s) permanent %s" % [p, _queue_attach[p].node, _queue_attach[p].permanent])
				if _queue_attach[p].has("signal"):
					emit_signal("gamestate_log", "qatc: signal %s(%s) permanent %s" % [p, _queue_attach[p].signal, _queue_attach[p].permanent])
		else:
			return #if scene is the same skip notifications
		if get_tree().current_scene:
			var scene = get_tree().current_scene
			for p in _queue_attach:
				if _queue_attach[p].has("scene") and _queue_attach[p].scene == scene:
					continue
				var obj = scene.get_node(p)
				if obj:
					#if signal emit and continue
					if _queue_attach[p].has("signal"):
						var sig = _queue_attach[p].signal
						if not _queue_attach[p].permanent:
							emit_signal("log_gamestate", "qatc, emit and remove: %s(%s) permanent %s" % [p, _queue_attach[p].signal, _queue_attach[p].permanent])
							_queue_attach.erase(p)
							emit_signal(sig)
						else:
							_queue_attach[p]["scene"] = scene
							emit_signal(sig)
						continue
					print("==qaotc== object at(%s) - %s" % [p, obj])
					var obj2 = _queue_attach[p].packedscene
					_queue_attach_on_tree_change_lock = true
					obj.add_child(obj2.instance())
					_queue_attach_on_tree_change_lock = false
					if not _queue_attach[p].permanent:
						emit_signal("log_gamestate", "qatc, attached and removed: %s(%s) permanent %s" % [p, _queue_attach[p].node, _queue_attach[p].permanent])
						_queue_attach.erase(p)
						scene.print_tree_pretty()
					else:
						_queue_attach[p]["scene"] = scene

func _on_net_connection_fail() -> void:
	printd("***********net_connection_fail")
	NetworkUP = false

func _on_net_client_connected(id : int) -> void:
	printd("***********net_client_connected(%s)" % id)
	net_client(id, true)

func _on_net_client_disconnected(id : int) -> void:
	printd("***********net_client_disconnected(%s)" % id)
	net_client(id, false)

func _on_net_server_connected() -> void:
	printd("***********net_server_connected")
	if not NetworkUP:
		NetworkUP = true
		net_up()

func _on_net_server_disconnected() -> void:
	printd("***********net_server_disconnected")
	if NetworkUP:
		NetworkUP = false
		net_down()

func _on_net_server_up() -> void:
	printd("***********net_server_up")
	if not NetworkUP:
		NetworkUP = true
		net_up()

func _on_server_tree_changed() -> void:
	if not RoleServer or not server.up:
		return
	var root = get_tree()
	if root != null and root.get_network_unique_id() == 0:
		root.set_network_peer(server.connection)
		emit_signal("network_log", "reconnect server to tree")

func _on_server_user_connected(id : int) -> void:
	emit_signal("log_gamestate", "user connected %s" % id)

func _on_server_user_disconnected(id : int) -> void:
	emit_signal("log_gamestate", "user disconnected %s" % id)

func _on_server_tree_user_connected(id : int) -> void:
	emit_signal("log_gamestate", "tree user connected %s" % id)

func _on_server_tree_user_disconnected(id : int) -> void:
	emit_signal("log_gamestate", "tree user disconnected %s" % id)
	unregister_client(id)


func _on_player_scene() -> void:
	emit_signal("log_gamestate", "scene is player ready, checking players(%s)" % players.size())
	if options.debug:
		for p in players:
			emit_signal("log_gamestate", "player %s" % players[p])
	for p in players:
		create_player(p)
	
	#The ChatUI should only be added when there is networking going on.
	if RoleClient or RoleServer:
		add_chat_ui()
	
	if RoleClient:
		#report client to server
		rpc_id(1, "register_client", network_id, players[local_id].data)


func _on_player_id(id : int) -> void:
	if not players.has(local_id):
		return
	player_remap_id(local_id, id)
	local_id = id
	#scene is not active yet, payers are redistered after scene is changes sucessefully


func _server_disconnected() -> void:
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail() -> void:
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

func _on_connection_failed() -> void:
	emit_signal("log_gamestate", "client connection failed to %s(%s):%s" % [player_get("host"), player_get("ip"), player_get("port")])
	bind_signal("connection_failed", '', get_tree(), self, MODE.DISCONNECT)
	bind_signal("connected_to_server", '', get_tree(), self, MODE.DISCONNECT)
	RoleClient = false
	emit_signal("network_error", "Error connecting to server %s(%s):%s" % [player_get("host"), player_get("ip"), player_get("port")])

func _on_connected_to_server() -> void:
	emit_signal("log_gamestate", "client connected to %s(%s):%s" % [player_get("host"), player_get("ip"), player_get("port")])
	bind_signal("connection_failed", '', get_tree(), self, MODE.DISCONNECT)
	bind_signal("connected_to_server", '', get_tree(), self, MODE.DISCONNECT)
	RoleClient = true
	emit_signal("server_connected")

func _on_network_log(msg) -> void:
	printd("Server log: %s" % msg)

func _on_gamestate_log(msg) -> void:
	printd("gamestate log: %s" % msg)

func _on_scene_change_log() -> void:
	printd("===gs on_scene_change")
	printd("get_tree: %s" % get_tree())
	if get_tree():
		if get_tree().current_scene :
			printd("current scene: %s" % get_tree().current_scene)
