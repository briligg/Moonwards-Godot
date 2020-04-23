extends ANetworkInstance
class_name GameClient

export(String) var Test

var ip: String = ""
var port: int = 0
var peer_id: int = -1

func _init(_ip: String, _port: int):
	self.ip = _ip
	self.port = _port

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	_join_server()

func _join_server() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	self.peer_id = get_tree().get_network_unique_id()

func _connected_ok():
	Log.trace(self, "", "CONNECTED.")

func _server_disconnected():
	Log.trace(self, "", "DISCONNECTED.")
	self.queue_free()

func _connected_fail():
	Log.warning(self, "", "CONNECTION FAILED!")

# The initial loading of all existing players upon connection.
puppet func initial_client_load_entities(players_data: Array) -> void:
	for p_data in players_data:
		var p = PlayerData.new().deserialize(p_data)
		self.players[p.peer_id] = p
	for player in self.players.values():
		add_player(player)
	
	crpc_signal(Signals.Network, Signals.Network.CLIENT_LOAD_FINISHED, self.peer_id)
	Log.trace(self, "", "LOADED PLAYERS %s" %players)
