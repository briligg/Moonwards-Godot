extends Node
class_name NetworkManager

#onready var GameServer = GameServer.new()
## Temporary, to be replaced with environment vars before getting defaulted.
const SERVER_IP: String = "127.0.0.1"
const SERVER_PORT: int = 5000
const MAX_PLAYERS: int = 1000

var _network_instance = null

func _ready():
	Signals.Network.connect(Signals.Network.GAME_SERVER_REQUESTED, 
			self, "_set_game_server")
	Signals.Network.connect(Signals.Network.GAME_CLIENT_REQUESTED, 
			self, "_set_game_client")

func _set_game_server() -> void:
	_network_instance = GameServer.new(SERVER_PORT, MAX_PLAYERS)
	
func _set_game_client() -> void:
	_network_instance = GameClient.new(SERVER_IP, SERVER_PORT)
