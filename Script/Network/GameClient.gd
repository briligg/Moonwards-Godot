extends ANetworkInstance
class_name GameClient

export(String) var Test

var ip: String = ""
var port: int = 0

var is_version_approved: bool = false

func _init(_ip: String, _port: int):
	self.ip = _ip
	self.port = _port

func _ready() -> void:
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	_join_server()

func _join_server() -> void:
	self.multiplayer_peer = NetworkedMultiplayerENet.new()
	self.multiplayer_peer.create_client(ip, port)
	self.multiplayer_peer.always_ordered = Network.IS_ALWAYS_ORDERED
	self.multiplayer_peer.compression_mode = Network.COMPRESS_MODE
	
	get_tree().set_network_peer(self.multiplayer_peer)
	self.peer_id = get_tree().get_network_unique_id()

func _connected_ok():
	Log.trace(self, "_connected_ok", "Connection to the server successful.")
	# Request version approval if we just connected
	if !is_version_approved:
		rpc_id(1, "request_join_server", WorldConstants.VERSION)
	# Join the server after loading, if we're already approved.
	else:
		rpc_id(1, "initialize_entity_data", Network.self_meta_data.name, 
				Network.self_meta_data.colors, Network.self_meta_data.gender)

func _connected_fail():
	Log.warning(self, "_connected_fail", "Connection to the server failed!")
	disconnect_instance()
	get_tree().change_scene(Scene.main_menu)
	Helpers.UI.show_notice("[center]Connection to the server was unsuccessful.\n"
			+ "The server might be temporarily unavailable, or your internet connection may be down.[/center]")
	self.queue_free()
	
func _server_disconnected():
	Log.trace(self, "", "DISCONNECTED.")
	disconnect_instance()
	get_tree().change_scene(Scene.main_menu)
	self.queue_free()

puppet func accept_join_server():
	Log.trace(self, "", "Connection to server accepted.")
	disconnect_instance()
	is_version_approved = true
	load_world()
	yield(self, "world_loaded")
	_join_server()

puppet func decline_join_server(message):
	Log.trace(self, "refuse_join_server", message)
	Helpers.UI.show_notice("%s" %message)
	disconnect_instance()

# The initial loading of all existing entities upon connection.
puppet func initial_client_load_entities(entities_data: Array) -> void:
	for e_data in entities_data:
		var p = EntityData.new().deserialize(e_data)
		self.entities[p.peer_id] = p
	for entity in self.entities.values():
		add_player(entity)
	
	crpc_signal(Signals.Network, Signals.Network.CLIENT_LOAD_FINISHED, self.peer_id)
	Log.trace(self, "", "LOADED ENTITIES %s" %entities)
