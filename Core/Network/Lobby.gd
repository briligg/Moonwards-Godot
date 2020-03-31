extends Node

enum MODE {
	DISCONNECTED = 0,
	CLIENT = 1,
	SERVER = 2,
	NONETWORK = -1
	}
	
# warning-ignore-all:return_value_discarded

### Singals to interface with (not to be used inside this script ###

signal user_disconnected(name) #emit when user is joined, for chat
signal user_connected(name) #emit when user is disconnected, for chat
signal server_up

### Signals to be used inside this script ###

signal loading_done()
signal loading_error(msg)
signal player_id(id) #emit id of player after establishing a connection
signal player_scene
#network server

#network client
signal server_connected
#network general
signal client_connected


# Signals to let lobby GUI know what's going on
signal connection_failed

signal game_ended
signal game_error(what)


const DEFAULT_PORT : int = 10567 # Default game port
const MAX_PEERS : int = 12 # Max number of players

const CONNECTION_TIMEOUT = 25


var global_delta : float


### This is misterious legacy code that is necessary to run this script. Must be resolved ###########################
var _queue_attach : Dictionary = {}
var _queue_attach_on_tree_change_lock : bool = false #emits tree_change events on adding node, prevent stack overflow
var _queue_attach_on_tree_change_prev_scene : String
#####################################################################################################################


var players : Dictionary = {} #This contains all the players at all the times, 
# the format is players[id], each id contains another dict with the user's specific
# information, like the name, its avatar colors, etc.


### Connection and local user details ###
var network_id : int
var local_id : int = 0
var host : String = "localhost"
var ip : String = "127.0.0.1"
var connection = null
var port : int = DEFAULT_PORT
var NetworkState : int = MODE.DISCONNECTED # 0 disconnected. 1 Connected as client. 2 Connected as server -1 Error

var currently_check_id_is_connected : bool = false
onready var has_player_scene : bool = false
signal recieved_check_id
signal check_or_timeout

func _ready():
	local_id = 0
	queue_tree_signal("players", "player_scene", true)
	_connect_signals()

func _exit_tree():
	get_tree().set_network_peer(null)
	
	
######################## THIS BLOCK OF CODE MANAGES CONNECTION PINGS ###########


remote func ping_user(id : int) -> void:
	if get_tree().is_network_server():
		#The server will send the instruction to execute this function, using
		#the server's id
		rpc_id(id, "ping_user", get_network_master())
	else:
		#The clients that recieve the order to execute the function will recieve
		#the server's id, and will use set_current_id, true
		rpc_id(id, "set_check_for_id", true)

remote func set_check_for_id(connected : bool = false) -> void:
	currently_check_id_is_connected = connected
	emit_signal("recieved_check_id")

func check_or_timeout():
	#This signal is emmited whether the current timer times-out or if the
	#connection assert is finished
	emit_signal("check_or_timeout")

remote func assert_user_connection(id : int) -> bool:
	connect("recieved_check_id", self, "check_or_timeout")
	ping_user(id)
	get_tree().create_timer(4).connect("timeout", self, "check_or_timeout")
	yield(self, "check_or_timeout")
	if currently_check_id_is_connected:
		currently_check_id_is_connected = false
		return true
	else: 
		return false
	
	
###################### END OF CONNECTION ASSERTION BLOCK #######################

################################################################################
#Track scene changes and add nodes or emit signals functions



func unreliable_call(delta : float, function : String, args : Dictionary = {}, id : int = -1):
	if get_tree().get_network_peer():
		if delta < 0.1:
			global_delta += delta
		if global_delta > 0.1:
			if id!=-1:
				rpc_unreliable_id(id, function, args)
			else:
				rpc_unreliable(function, args)
			global_delta = 0
	else: 
		print("Tried to send an unreliable rcp wtihout a network peer")
		
func reliable_call(delta : float, function : String, args : Dictionary = {}, id : int = -1):
	if get_tree().get_network_peer():
		if delta < 0.1:
			global_delta += delta
		if global_delta > 0.1:
			if id!=-1:
				rpc_id(id, function, args)
			else:
				rpc(function, args)
			global_delta = 0
	else:
		print("Tried to send an RCP without a network peer")

func queue_attach(path : String, node, permanent : bool = false) -> void: #node is variant
	Log.hint(self, "queue_attach", str("attach queue(permanent: ", str(permanent),"): ", path, "(", node, ")"))
	var packedscene
	if node is String:
		packedscene = ResourceLoader.load(node)
		Log.hint(self, "queue_attach", str("loading resource in queue_attach(", path, ", ", node, ", ", permanent,")"))
		if not packedscene:
			Log.error(self, "queue_attach", str("error loading resource in queue_attach(", path, ", ", node, ", ", permanent,")"))
			return
	if not packedscene:
		packedscene = node
	_queue_attach[path] = {
			path = path,
			permanent = permanent,
			node = node,
			packedscene = packedscene
		}
	Log.hint(self, "queue_attach", str("+++", _queue_attach[path].packedscene))
	NodeUtilities.bind_signal("tree_changed","_on_queue_attach_on_tree_change", get_tree(), self, NodeUtilities.MODE.CONNECT)

func queue_tree_signal(path : String, signal_name : String, permanent : bool = false) -> void:
	Log.hint(self, "queue_tree_signal", "signal queue(permanent %s): %s(%s)" % [permanent, path, signal_name])
	_queue_attach[path] = {
			path = path,
			permanent = permanent,
			signal = signal_name,
		}
	NodeUtilities.bind_signal("tree_changed", "_on_queue_attach_on_tree_change", get_tree(), self, NodeUtilities.MODE.CONNECT)

#################
#Connection functions

func connect_to_server(player_data : Dictionary, as_host: bool = true, server : String = "localhost", port : int = DEFAULT_PORT) -> void:
	NodeUtilities.bind_signal("server_up", "_on_successful_connection", self, self, NodeUtilities.MODE.CONNECT)
	if as_host:
		server_set_mode(port)
	else:
		client_server_connect(server)
		NodeUtilities.bind_signal("client_connected", "_on_successful_connection", self, self, NodeUtilities.MODE.CONNECT)

	yield(WorldManager, "scene_change") #Wait Until the world loads
	print("World loaded, setting up server bot 3/4")

	player_register(player_data, true) #local player

func verify_connection_mode(mode_to_check : int) -> bool:
	if MODE.DISCONNECTED or mode_to_check:
		NetworkState = mode_to_check
		return true
	else:
		Log.error(self, "verify_connection_mode", "Connection mode was already set to a different Mode")
		return false


func server_set_mode(port : int = DEFAULT_PORT):
	
	if not verify_connection_mode(MODE.SERVER):
		return
		
	Log.hint(self, "server_set_mode", str("prepare to listen on ", ip, ":", DEFAULT_PORT))
	
	connection = NetworkedMultiplayerENet.new() #Create Connection resource
	connection.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_FASTLZ) #Set compression mode for the connection
	connection.set_bind_ip("*") # Temporary debug stuff, use all available interfaces
	
	var error : int = connection.create_server(DEFAULT_PORT, MAX_PEERS) #Establish a connection
	
	
	print("Current connection status: " + Log.error_to_string(error))
	
	if error == OK:
		print("Server has been connected: 2/4")
		emit_signal("server_up")
		yield(WorldManager, "scene_change")
		get_tree().set_network_peer(connection)
		Log.hint(self, "server_set_mode", str("server up on ", ip, ":", DEFAULT_PORT))
		NetworkState = MODE.SERVER
		NodeUtilities.bind_signal("tree_changed", "_on_server_tree_changed", get_tree(), self, NodeUtilities.MODE.CONNECT)
		NodeUtilities.bind_signal("peer_disconnected", "_on_server_user_disconnected", connection, self, NodeUtilities.MODE.CONNECT)
		NodeUtilities.bind_signal("peer_connected", "_on_server_user_connected", connection, self, NodeUtilities.MODE.CONNECT)
		NodeUtilities.bind_signal("network_peer_connected", "_on_server_tree_user_connected", get_tree(), self, NodeUtilities.MODE.CONNECT)
		NodeUtilities.bind_signal("network_peer_disconnected", "_on_server_tree_user_disconnected", get_tree(), self, NodeUtilities.MODE.CONNECT)
		network_id = connection.get_unique_id()
		Log.hint(self, "server_set_mode", str("network server id ", network_id))
		emit_signal("player_id", network_id)
	else:
		Log.hint(self, "server_set_mode", "server error %s" % Log.error_to_string(error))
		Log.hint(self, "server_set_mode", "failed to bring server up, error %s" % Log.error_to_string(error))
		NetworkState = MODE.DISCONNECTED

################ #Client functions

func client_server_connect(host : String, port : int = DEFAULT_PORT):
	
	if not verify_connection_mode(MODE.CLIENT):
		return

	ip = IP.resolve_hostname(host, IP.TYPE_ANY) #TYPE_ANY, allows IPv4 and IPv6
	
	if not ip.is_valid_ip_address():
		Log.error(self, "client_server_connect", str("fail to resolve host(", host, ") to ip adress"))
		NetworkState = MODE.DISCONNECTED
		return
		
	Log.hint(self, "client_server_connect", "connect to server %s(%s):%s" % [host, ip, port])
	NodeUtilities.bind_signal("connection_failed", "", get_tree(), self, NodeUtilities.MODE.CONNECT)
	NodeUtilities.bind_signal("connected_to_server", "", get_tree(), self, NodeUtilities.MODE.CONNECT)
	
	
	connection = NetworkedMultiplayerENet.new()
	connection.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_FASTLZ) #Use lss bandwidth
	var err = connection.create_client(ip, port)
	
	
	print("Current connection status: " + Log.error_to_string(err))
	
	emit_signal("server_up")
	
	Log.hint(self, "client_server_connect", str("network id ", connection.get_unique_id()))
	network_id = connection.get_unique_id()
	emit_signal("player_id", network_id)

	yield(WorldManager, "scene_change") #Stop your horses, the world hasn't loaded in yet!
	get_tree().set_network_peer(connection)
	yield(get_tree().create_timer(CONNECTION_TIMEOUT), "timeout") #25 is the connection timeout maximum value
	var error : int = get_tree().network_peer.get_connection_status() 
	#Line above: checks
	print("The connection status at the end of the attempt is : ", error, "(2== Connected, error otherwise)")
	print("error == 2:", error==2)
	if error != NetworkedMultiplayerENet.CONNECTION_CONNECTED: #if it times-out you get booted to the main menu 
	#( I hate to do this, but it seems that the comparison is done through floats)
		print("Error was different than 2, disconnecting")
		Input.MOUSE_MODE_VISIBLE
		yield(get_tree().create_timer(5), "timeout")
		end_game()


################
# Scene functions




func has_player_scene() -> bool:
	var result : bool = false
	if get_tree() and get_tree().current_scene:
		if get_tree().current_scene.has_node("players"):
			result = true
	return result

################
# Player functions

func player_register(player_data : Dictionary, localplayer : bool = false) -> void:
	#print("registering a player, id: ", player_data.id)
	var id : int = 0
	if localplayer and network_id:
		id = network_id
	elif localplayer:
		id = local_id
	elif player_data.has("id"):
		id = player_data.id
	else:
		Log.hint(self, "player_register", "player data should have id or be a local")
		return

	Log.hint(self, "player_register", "registered player(%s): %s" % [id, player_data])

	WorldManager.player_apply_opt(player_data, Options.player_scene.instance())
# 	player["localplayer"] = localplayer
	if localplayer:
		if network_id :
			player_data["id"] = id
		players[id] = player_data
	else:
		player_data["id"] = id
		players[id] = player_data

	if has_player_scene():
		print("creating a player!")
		WorldManager.create_player(players[id])
		
#local player recieved network id

remote func register_client(id : int, pdata : Dictionary = Options.player_data) -> void:
	if id == local_id:
		return
	if players.has(id):
		return
#	print("register_client: id(%s), data: %s" % [id, pdata])
	pdata["id"] = id
	if pdata.has("Options"):
		pdata["Options"] = Options.player_opt("puppet", pdata["Options"])
	else:
		pdata["Options"] = Options.player_opt("puppet")
	player_register(pdata)
	if NetworkState == MODE.SERVER:
		#sync existing players
		rpc("register_client", id, pdata)
		for p in players:
			if assert_user_connection(p):
				var pid = players[p].id
				if pid != id:
					rpc_id(id, "register_client", pid, players[p])

remote func unregister_client(id : int) -> void:
	
	Log.hint(self, "unregister client", str("(",id,")"))
	if players.has(id):
		emit_signal("user_disconnected", "%s" % player_get_property("username", id))
		if players[id].instance:
			players[id].instance.queue_free()
		players.erase(id)
		if NetworkState == MODE.SERVER:
			#sync existing players
			for p in players:
				Log.hint(self, "unregister_client", "**** %s" % players[p])
				var pid = players[p].id
				if pid != local_id:
					rpc_id(pid, "unregister_client", id)
	else:
		print("Tired to disconnect an non-existant user")

func player_get_property(prop : String, id : int = -1): #Result is variant, returns null 
	if id == -1:
		id = local_id
	var error : bool = false
	if not players.has(id):
		Log.error(self, "player_get_property", str("no such player: ", id))
		return null
	if players[id].has(prop):
		return players[id][prop]
	else:
		Log.error(self, "player_get_property", str("error: player data, no property:", prop))
		return null

#remap local user for its network id, when he gets it


#set current camera to local player
func player_local_camera(activate : bool = true) -> void:
	if players.has(local_id):
		players[local_id].instance.nocamera = !activate

func player_noinput(enable : bool = false) -> void:
	if players.has(local_id):
		players[local_id].instance.input_processing = enable

# Callback from SceneTree, only for clients (not server)

# Lobby management functions

func end_game() -> void:
	if (has_node("/root/world")): # Game is in progress
		get_node("/root/world").queue_free()
		WorldManager.change_scene("res://Boot.tscn")
	NetworkState = MODE.DISCONNECTED
	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null)
	# End networking

#################
# avatar network/scene functions

#network and player scene state
func _connect_signals(connect : bool = true) -> void:
	var tree = get_tree()
	var signals = [
		["connected_to_server", "", tree],
		["server_disconnected", "", tree],
		["connection_failed", "", tree],
		["network_peer_connected", "", tree],
		["network_peer_disconnected", "", tree],
		["player_scene", "", self],
		["player_id", "", self],
		["server_up", "", self]
	]
	for sg in signals:
		Log.hint(self, "_net_tree_connect_signals", str("net_tree_connect", sg[0], " -> " , sg[1]))
		if connect:
			NodeUtilities.bind_signal(sg[0], sg[1], sg[2], self, NodeUtilities.MODE.CONNECT)
		else:
			NodeUtilities.bind_signal(sg[0], sg[1], sg[2], self, NodeUtilities.MODE.DISCONNECT)



func _player_remap_id(old_id : int, new_id : int) -> void:
	if players.has(old_id):
		var player = players[old_id].duplicate(true)
		if not players.erase(old_id):
			print("Error erasing the old id: ", old_id)
		players[new_id] = player
		player["id"] = new_id
		Log.hint(self, "player_remap", str("remap player old_id: ", old_id, " new_id: ", new_id))
		var node = player.instance
		node.name = new_id
		var world = get_tree().current_scene
		node.set_network_master(new_id)


func _on_queue_attach_on_tree_change() -> void:
	if _queue_attach_on_tree_change_lock:
		return
	if get_tree():
		if _queue_attach_on_tree_change_prev_scene != str(get_tree().current_scene):
			_queue_attach_on_tree_change_prev_scene = str(get_tree().current_scene)
			Log.hint(self, "_on_queue_attach_on_tree_change", "qatc: Scene changed %s" % _queue_attach_on_tree_change_prev_scene)
			for p in _queue_attach:
				if _queue_attach[p].has("node"):
					Log.hint(self, "_on_queue_attach_on_tree_change", "qatc: node %s(%s) permanent %s" % [p, _queue_attach[p].node, _queue_attach[p].permanent])
				if _queue_attach[p].has("signal"):
					Log.hint(self, "_on_queue_attach_on_tree_change", "qatc: signal %s(%s) permanent %s" % [p, _queue_attach[p].signal, _queue_attach[p].permanent])
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
							Log.hint(self, "_on_queue_attach_on_tree_change","qatc, emit and remove: %s(%s) permanent %s" % [p, _queue_attach[p].signal, _queue_attach[p].permanent])
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
						Log.hint(self, "_on_queue_attach_on_tree_change", "qatc, attached and removed: %s(%s) permanent %s" % [p, _queue_attach[p].node, _queue_attach[p].permanent])
						_queue_attach.erase(p)
						scene.print_tree_pretty()
					else:
						_queue_attach[p]["scene"] = scene

func _on_connection_failed() -> void:
	Log.error(self, "_on_connection_failed", "client connection failed to %s(%s):%s" % [host, ip, port])
	NodeUtilities.bind_signal("connection_failed", "", get_tree(), self, NodeUtilities.MODE.DISCONNECT)
	NodeUtilities.bind_signal("connected_to_server", "", get_tree(), self, NodeUtilities.MODE.DISCONNECT)
	NetworkState = MODE.DISCONNECTED

func _on_network_peer_connected(id : int) -> void:
	var peers = get_tree().get_network_connected_peers()
	for peer in peers:
		if not players.has(peer) and peer!=id:
			unregister_client(peer)
	if not players.has(id):
		register_client(id)
	Log.hint(self, "on_network_peer_connected", str("Player: ", id, " connected"))
	emit_signal("client_connected")


func _on_network_peer_disconnected(id : int) -> void:
	Log.hint(self, "on_network_peer_disconnected", str("Player: ", id, " disconnected"))
	unregister_client(id)

func _on_server_connected() -> void:
	Log.hint(self, "on_server_connected", "Server connected")
	if not NetworkState == MODE.SERVER:
		NetworkState = MODE.SERVER

func _on_server_disconnected() -> void:
	print("Connection with server is lost")
	Log.hint(self, "on_server_disconnected", "Server disconnected")
	get_tree().set_network_peer(null)
	#FIXME Let the player try to re-connect
	end_game()

func _on_server_up() -> void:
	Log.hint(self, "on_server_up", "Server up")
	if not NetworkState == MODE.SERVER:
		NetworkState = MODE.SERVER

func _on_server_tree_changed() -> void:
	if not NetworkState == MODE.SERVER:
		return
	var root = get_tree()
	if root != null and root.get_network_unique_id() == 0:
		root.set_network_peer(connection)
		Log.hint(self, "_on_server_tree_changed", "reconnect server to tree")

func _on_server_user_connected(id : int) -> void:
	Log.hint(self, "_on_server_user_connected", "user connected %s" % id)

func _on_server_user_disconnected(id : int) -> void:
	Log.hint(self, "_on_server_user_disconnected","user disconnected %s" % id)

func _on_server_tree_user_connected(id : int) -> void:
	Log.hint(self, "_on_server_tree_user_connected", "tree user connected %s" % id)

func _on_server_tree_user_disconnected(id : int) -> void:
	Log.hint(self, "_on_server_tree_user_disconnected", "tree user disconnected %s" % id)
	


func _on_player_scene() -> void:
	print("Entered _on_player_scene")
	Log.hint(self, "_on_player_scene", "scene is player ready, checking players(%s)" % players.size())
	for p in players:
		WorldManager.create_player(players[p])

	if NetworkState == MODE.CLIENT:
		#report client to server
		print(players[local_id].instance, " Mode is client")
		rpc_id(1, "register_client", network_id, players[local_id])


func _on_player_id(id : int) -> void:
	print("Enter: _on_player_id, with id: ", id)
	if not players.has(local_id):
		print("Local Id wasn't in the player dictionary :/, attempting to remap any ways")
	_player_remap_id(local_id, id)
	local_id = id
	#scene is not active yet, payers are redistered after scene is changes sucessefully

func _on_connected_to_server() -> void:
	print("connected to server was emitted, now called _on_signal")
	Log.hint(self, "_on_connected_to_server",  "client connected to %s(%s):%s" % [host, ip, port])
	NodeUtilities.bind_signal("connection_failed", '', get_tree(), self, NodeUtilities.MODE.DISCONNECT)
	NodeUtilities.bind_signal("connected_to_server", '', get_tree(), self, NodeUtilities.MODE.DISCONNECT)
	NetworkState = MODE.CLIENT
	emit_signal("client_connected")

func _on_successful_connection():
	yield(get_tree().create_timer(2), "timeout")
	WorldManager.change_scene(Options.scenes.default)
