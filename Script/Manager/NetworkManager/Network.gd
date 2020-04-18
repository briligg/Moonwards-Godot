extends Node

func host_game() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(5000, 1000)
	get_tree().set_network_peer(peer)

