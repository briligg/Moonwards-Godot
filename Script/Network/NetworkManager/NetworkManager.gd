extends Node
class_name NetworkManager

#onready var GameServer = GameServer.new()
## Temporary, to be replaced with environment vars before getting defaulted.
const LOCAL_IP: String = "127.0.0.1"
const DEFAULT_PORT: int = 5000
const DEFAULT_MAX_PLAYERS: int = 100

var network_instance = null

# This is to be moved to a more full system once persistence is setup
var self_meta_data = {
	"name" : "No name set",
	# Temporary default values for testing
	"colors": []
}

func _ready() -> void:
	Signals.Network.connect(Signals.Network.GAME_SERVER_REQUESTED, 
			self, "_set_game_server")
	Signals.Network.connect(Signals.Network.GAME_CLIENT_REQUESTED, 
			self, "_set_game_client")
	Signals.Network.connect(Signals.Network.CLIENT_COLOR_CHANGED, 
			self, "_set_self_colors")
	Signals.Network.connect(Signals.Network.CLIENT_NAME_CHANGED, 
			self, "_set_self_name")

func _set_game_server(is_host_player: bool = false) -> void:
	var root = get_tree().get_root()
	network_instance = GameServer.new(DEFAULT_PORT, DEFAULT_MAX_PLAYERS, is_host_player)
	network_instance.name = "NetworkInstance"
	root.call_deferred("add_child", network_instance)
	
func _set_game_client(_ip, _port) -> void:
	var root = get_tree().get_root()
	network_instance = GameClient.new(_ip, _port)
	network_instance.name = "NetworkInstance"
	root.call_deferred("add_child", network_instance)

func _set_self_colors(colors: Array) -> void:
	self_meta_data.colors = colors

func _set_self_name(name: String) -> void:
	self_meta_data.name = name
	
## Networking API - to be better written in C++

func get_sender_entity() -> EntityData:
	var id = get_tree().get_rpc_sender_id()
	return network_instance.entities[id] as EntityData

func get_sender_id() -> int:
	return get_tree().get_rpc_sender_id()

# Controlled RPC Wrapper with added control.
func crpc(caller: Node, method: String, val):
	network_instance.crpc(caller, method, val)

# Controlled RPC Wrapper with added control.
func crpc_unreliable(caller: Node, method: String, val):
	network_instance.crpc_unreliable(caller, method, val)

# Controlled RSET Wrapper with added control.
func crset(caller: Node, method: String, val):
	network_instance.crset(caller, method, val)

# Controlled RSET Wrapper with added control.
func crset_unreliable(caller: Node, method: String, val):
	network_instance.crset_unreliable(caller, method, val)

# Controlled signal RPC
func crpc_signal(instance: Node, sig_name: String, param):
	network_instance.crpc_signal(instance, sig_name, param)
