extends Node
class_name GameServer

var port: int = 0
var max_players: int = 0

func _init(_port: int, _max_players: int):
	port = _port
	max_players = _max_players

func _ready():
	_host_game()

func _host_game() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players)
	get_tree().set_network_peer(peer)
