extends Node

#global signals
signal gslog(msg)
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
var local_id : String
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
var _queue_attach_on_tree_change_lock : bool= false #emits tree_change events on adding node, prevent stack overflow
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

	local_id = "local_%s_%s" % [randi(), randi()]

	bindgg("network_log")
	bindgg("gslog")
	bindgg("player_scene")
	bindgg("player_id")
	queue_tree_signal(options.scene_id, "player_scene", true)
	log_all_signals()
	
	connect("player_scene", self, "player_scene")
	net_tree_connect()

func bindsig(_signal, _sub, obj, obj2, d = 0):
	if _sub == null:
		_sub = "sg_%s" % _signal
	if d == 0:
		if obj.is_connected(_signal, obj2, _sub):
			obj.disconnect(_signal, obj2, _sub)
			emit_signal("gslog", "disconnect signal %s, from %s to %s::%s" % [_signal, obj, obj2, _sub])
		else:
			obj.connect(_signal, obj2, _sub)
			emit_signal("gslog", "connect signal %s, from %s to %s::%s" % [_signal, obj, obj2, _sub])
	elif d == 1 : #connect
		if not obj.is_connected(_signal, obj2, _sub):
			obj.connect(_signal, obj2, _sub)
	elif d == 2 : #disconnect
		if obj.is_connected(_signal, obj2, _sub):
			obj.disconnect(_signal, obj2, _sub)

func bindtg(_signal, _sub = null):
	#connect or disconnect tree to gamestate
	var obj = get_tree()
	var obj2 = self
	bindsig(_signal, _sub, obj, obj2, 0)

func bindtgc(_signal, _sub = null):
	#connect tree to gamestate
	var obj = get_tree()
	var obj2 = self
	bindsig(_signal, _sub, obj, obj2, 1)

func bindtgd(_signal, _sub = null):
	#disconnect tree from gamestate
	var obj = get_tree()
	var obj2 = self
	bindsig(_signal, _sub, obj, obj2, 2)

func bindgg(_signal, _sub = null):
	#bind gamestate to gamestate
	var obj = self
	var obj2 = self
	bindsig(_signal, _sub, obj, obj2, 0)

#################
#Track scene changes and add nodes or emit signals functions


func queue_attach(path, node, permanent = false):
	emit_signal("gslog", "attach queue(permanent %s): %s(%s)" % [permanent, path, node])
	var packedscene
	if node.get_class() == "String":
		packedscene = ResourceLoader.load(node)
		emit_signal("gslog", "loading resource in queue_attach(%s, %s, %s)" % [path, node, permanent])
		if not packedscene:
			emit_signal("gslog", "error loading resource in queue_attach(%s, %s, %s)" % [path, node, permanent])
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
	if not get_tree().is_connected("tree_changed", self, "queue_attach_on_tree_change") :
		get_tree().connect("tree_changed", self, "queue_attach_on_tree_change")

func queue_tree_signal(path, sig, permanent = false):
	emit_signal("gslog", "signal queue(permanent %s): %s(%s)" % [permanent, path, sig])
	_queue_attach[path] = {
			path = path,
			permanent = permanent,
			signal = sig,
		}
	if not get_tree().is_connected("tree_changed", self, "queue_attach_on_tree_change") :
		get_tree().connect("tree_changed", self, "queue_attach_on_tree_change")
	


func queue_attach_on_tree_change():
	if _queue_attach_on_tree_change_lock:
		return
	if get_tree():
		if _queue_attach_on_tree_change_prev_scene != str(get_tree().current_scene):
			_queue_attach_on_tree_change_prev_scene = str(get_tree().current_scene)
			emit_signal("gslog", "qatc: Scene changed %s" % _queue_attach_on_tree_change_prev_scene)
			for p in _queue_attach:
				if _queue_attach[p].has("node"):
					emit_signal("gslog", "qatc: node %s(%s) permanent %s" % [p, _queue_attach[p].node, _queue_attach[p].permanent])
				if _queue_attach[p].has("signal"):
					emit_signal("gslog", "qatc: signal %s(%s) permanent %s" % [p, _queue_attach[p].signal, _queue_attach[p].permanent])
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
							emit_signal("gslog", "qatc, emit and remove: %s(%s) permanent %s" % [p, _queue_attach[p].signal, _queue_attach[p].permanent])
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
						emit_signal("gslog", "qatc, attached and removed: %s(%s) permanent %s" % [p, _queue_attach[p].node, _queue_attach[p].permanent])
						_queue_attach.erase(p)
						scene.print_tree_pretty()
					else:
						_queue_attach[p]["scene"] = scene


#################
# signal logging functions

func sg_network_log(msg):
	printd("Server log: %s" % msg)

func sg_gslog(msg):
	printd("gamestate log: %s" % msg)

func on_scene_change_log():
	printd("===gs on_scene_change")
	printd("get_tree: %s" % get_tree())
	if get_tree():
		if get_tree().current_scene :
			printd("current scene: %s" % get_tree().current_scene)


#################
# general network functions

func net_getsocket():
	var ns = NetworkedMultiplayerENet.new()
	return ns

func net_tree_connect(bind=true):
	var tree = get_tree()
	
	var signals = [
		["connected_to_server", "net_server_connected", tree],
		["server_disconnected", "net_server_disconnected", tree],
		["connection_failed", "net_connection_fail", tree],
		["network_peer_connected", "net_client_connected", tree],
		["network_peer_disconnected", "net_client_disconnected", tree],
		["server_up", "net_server_up", self]
	]
	#connected_to_server()Emitted whenever this SceneTree's network_peer successfully connected to a server. Only emitted on clients.
	#server_disconnected()Emitted whenever this SceneTree's network_peer disconnected from server. Only emitted on clients.

	#connection_failed()Emitted whenever this SceneTree's network_peer fails to establish a connection to a server. Only emitted on clients.

	#network_peer_connected( int id )Emitted whenever this SceneTree's network_peer connects with a new peer. ID is the peer ID of the new peer. Clients get notified when other clients connect to the same server. Upon connecting to a server, a client also receives this signal for the server (with ID being 1).
	#network_peer_disconnected( int id )Emitted whenever this SceneTree's network_peer disconnects from a peer. Clients get notified when other clients disconnect from the same server.
	for sg in signals:
		printd("net_tree_connect %s -> %s" % [sg[0], sg[1]])
		if bind:
			sg[2].connect(sg[0], self, sg[1])
		else:
			sg[2].disconnect(sg[0], self, sg[1])

func net_connection_fail():
	printd("***********net_connection_fail")
	NetworkUP = false

func net_client_connected(id):
	printd("***********net_client_connected(%s)" % id)
	net_client(id, true)

func net_client_disconnected(id):
	printd("***********net_client_disconnected(%s)" % id)
	net_client(id, false)

func net_server_connected():
	printd("***********net_server_connected")
	if not NetworkUP:
		NetworkUP = true
		net_up()

func net_server_disconnected():
	printd("***********net_server_disconnected")
	if NetworkUP:
		NetworkUP = false
		net_down()

func net_server_up():
	printd("***********net_server_up")
	if not NetworkUP:
		NetworkUP = true
		net_up()

#################
#Server functions


func server_set_mode(host="localhost"):
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
	var error = server.connection.create_server(DEFAULT_PORT, MAX_PEERS)
	if error == 0:
		get_tree().set_network_peer(server.connection)
		emit_signal("network_log", "server up on %s:%s" % [server.ip,DEFAULT_PORT])
		server.up = true
		bindtgc("tree_changed", "server_tree_changed")
		emit_signal("server_up")
		server.connection.connect("peer_connected", self, "server_user_connected")
		server.connection.connect("peer_disconnected", self, "server_user_disconnected")
# 		emit_signal("connection_succeeded")
		get_tree().connect("network_peer_connected", self, "server_tree_user_connected")
		get_tree().connect("network_peer_disconnected", self, "server_tree_user_disconnected")

		emit_signal("gslog", "network server id %s" % server.connection.get_unique_id())
		network_id = server.connection.get_unique_id()
		emit_signal("player_id", network_id)
	else:
		emit_signal("network_log", "server error %s" % error)
		emit_signal("network_error", "failed to bring server up, error %s" % error)
		RoleServer = false
# 		emit_signal("connection_failed")

func server_tree_changed():
	if not RoleServer or not server.up:
		return
	var root = get_tree()
	if root != null and root.get_network_unique_id() == 0:
		root.set_network_peer(server.connection)
		emit_signal("network_log", "reconnect server to tree")

func server_user_connected(id):
	emit_signal("gslog", "user connected %s" % id)

func server_user_disconnected(id):
	emit_signal("gslog", "user disconnected %s" % id)

func server_tree_user_connected(id):
	emit_signal("gslog", "tree user connected %s" % id)

func server_tree_user_disconnected(id):
	emit_signal("gslog", "tree user disconnected %s" % id)
	unregister_client(id)

################
#Client functions


func sg_connection_failed():
	emit_signal("gslog", "client connection failed to %s(%s):%s" % [player_get("host"), player_get("ip"), player_get("port")])
	bindtgd("connection_failed")
	bindtgd("connected_to_server")
	RoleClient = false
	emit_signal("network_error", "Error connecting to server %s(%s):%s" % [player_get("host"), player_get("ip"), player_get("port")])

func sg_connected_to_server():
	emit_signal("gslog", "client connected to %s(%s):%s" % [player_get("host"), player_get("ip"), player_get("port")])
	bindtgd("connection_failed")
	bindtgd("connected_to_server")
	RoleClient = true
	emit_signal("server_connected")

func client_server_connect(host, port=DEFAULT_PORT):
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
	
	bindtgc("connection_failed")
	bindtgc("connected_to_server")
	client.connection = net_getsocket()
	client.connection.create_client(player_get("ip"), player_get("port"))
	emit_signal("gslog", "network id %s" % client.connection.get_unique_id())
	network_id = client.connection.get_unique_id()
	emit_signal("player_id", network_id)
	get_tree().set_network_peer(client.connection)


################
# Scene functions
func change_scene(scene):
	var scenes = options.scenes
	if not scene in scenes:
		emit_signal("scene_change_error", "No such scene %s" % scene)
		emit_signal("gslog", "No such scene %s" % scene)
		return
	
	emit_signal("gslog", "change_scene to %s" % scene)
	var error = get_tree().change_scene(scenes[scene].path)
	if error == 0 :
		emit_signal("gslog", "changing scene okay(%s)" % error)
		scenes.loaded = scene
		emit_signal("scene_change")
		emit_signal("scene_change_name", scene)
	else:
		emit_signal("gslog", "error changing scene %s" % error)

func sg_player_scene():
	emit_signal("gslog", "scene is player ready, checking players(%s)" % players.size())
	if options.debug:
		for p in players:
			emit_signal("gslog", "player %s" % players[p])
	for p in players:
		create_player(p)
	
	#The ChatUI should only be added when there is networking going on.
	if RoleClient or RoleServer:
		AddChatUI()
	
	if RoleClient:
		#report client to server
		rpc_id(1, "register_client", network_id, players[local_id].data)


func is_player_scene():
	var result = false
	if get_tree() and get_tree().current_scene:
		if get_tree().current_scene.has_node(options.scene_id):
			result = true
	return result

################
# Player functions
func player_apply_opt(pdata, player, id):
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

func player_register(pdata, localplayer=false, opt_id = "avatar"):
	var id
	if localplayer:
		pdata["options"] = options.player_opt(opt_id, pdata) #merge name with rest of options for Avatar
		if network_id:
			id = network_id
		else:
			id = local_id
	elif pdata.has("id"):
		id = pdata.id
	else:
		emit_signal("gslog", "player data should have id or be a local")
		return
	
	emit_signal("gslog", "registered player(%s): %s" % [id, pdata])
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
func sg_player_id(id):
	if not players.has(local_id):
		return
	player_remap_id(local_id, id)
	local_id = id
	#scene is not active yet, payers are redistered after scene is changes sucessefully

remote func register_client(id, pdata):
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

remote func unregister_client(id):
	emit_signal("gslog", "unregister client (%s)" % id)
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


func player_get(prop, id=null):
	if id == null:
		id = local_id
	var error = false
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
		emit_signal("gslog", "error: player data, no property(%s)" % prop)
	return result

#remap local user for its network id, when he gets it
func player_remap_id(oid, nid):
	if players.has(oid):
		var player = players[oid]
		players.erase(oid)
		players[nid] = player
		player["id"] = nid
		emit_signal("gslog", "remap player oid(%s), nid(%s)" % [oid, nid])
		if player.has("path"):
			var node = player.obj
			node.name = "%s" % nid
			var world = get_tree().current_scene
			emit_signal("gslog", "remap player, old path %s to %s" % [player.path, world.get_path_to(node)])
			player["path"] = world.get_path_to(node)
			node.set_network_master(nid)

func create_player(id):
	var world = get_tree().current_scene
	if players[id].has("world") and players[id]["world"] == str(world):
		emit_signal("gslog", "player(%s) already added, %s" % [id, players[id]])
		return
	var spawn_pcount =  world.get_node("spawn_points").get_child_count()
	var spawn_pos = randi() % spawn_pcount
	emit_signal("gslog", "select spawn point(%s/%s)" % [spawn_pos, spawn_pcount])
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
	
	emit_signal("gslog", "==create player(%s) %s; name(%s)" % [id, players[id], players[id].data.username])
	world.get_node("players").add_child(player)
	players[id]["world"] = "%s" % world
	players[id]["path"] = world.get_path_to(player)
	emit_signal("user_name_connected", player_get("name", id))

#set current camera to local player
func player_local_camera(activate = true):
	if players.has(local_id):
		players[local_id].obj.nocamera = !activate

func player_noinput(enable = false):
	if players.has(local_id):
		players[local_id].obj.input_processing = enable

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

func end_game():
	if (has_node("/root/world")): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

#################
# debug functions


func printd(s):
	logg.print_fd(debug_id, s)

func log_all_signals():
	var sg_ignore = ["gslog"]
	var sg_added = ""
	for sg in get_signal_list():
		if sg.name in sg_ignore:
			continue
		#printd("log all signals connect %s" % sg)
		sg_added = "%s(%s) %s" % [sg.name, sg.args.size(), sg_added]
		connect(sg.name, self, "log_all_signals_print_%s" % (sg.args.size()+1), ["%s" % sg.name])
	printd("log_all_signals: %s" % sg_added)
		
func log_all_signals_print_1(sg):
	printd("==========signal0 %s ================" % sg)
func log_all_signals_print_2(a1, sg):
	printd("==========signal1 %s ================" % sg)
	printd("%s" % a1)
func log_all_signals_print_3(a1, a2, sg):
	printd("==========signal2 %s ================" % sg)
	printd("%s, %s" % [a1, a2])

#################
# New UI functions



func loading_done(var error):
	if error == OK or error == ERR_FILE_EOF:
		emit_signal("gslog", "changing scene okay(%s)" % level_loader.error)
		emit_signal("loading_done")
	else:
		emit_signal("gslog", "error changing scene %s" % level_loader.error)
		emit_signal("loading_error", "Error! " + str(error))

func load_level(var resource):
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


func net_up():
	if PlayerSceneUP:
		printd("------net_up---enable networking in instanced players--------")
	else:
		printd("------net_up---do nothing--------")

func net_down():
	if PlayerSceneUP:
		printd("------net_down---players disable netwokring--------")
	else:
		printd("------net_down---players do nothing--------")

func net_client(id, connected):
	if connected:
		printd("------net_client(%s)---make stub for %s---------" % [connected, id])
	else:
		printd("------net_client(%s)---disconnect client %s-----" % [connected, id])

func player_scene():
	printd("------instance avatars with networking(%s) - players count %s" % [NetworkUP, players.size()])
	PlayerSceneUP = true

func AddChatUI():
	if not is_instance_valid(chat_ui):
		chat_ui = chat_ui_resource.instance()
		get_tree().root.add_child(chat_ui)
