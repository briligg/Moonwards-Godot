extends Node
class_name GameClient

var ip: String = ""
var port: int = 0

func _init(_ip: String, _port: int):
	ip = _ip
	port = _port

func _ready():
	_join_server()

func _join_server() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
