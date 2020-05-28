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
	# because inheritence is broken on yields
	# yielding on a parent class' _ready returns it to the inheriting class' _ready
	if !self.is_initialized:
		yield(self, "initialized")
		
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
	rpc_id(1, "initialize_entity_data", Network.self_meta_data.name, Network.self_meta_data.colors)
	Log.trace(self, "", "CONNECTED.")

func _server_disconnected():
	Log.trace(self, "", "DISCONNECTED.")
	get_tree().change_scene(Scene.main_menu)
	self.queue_free()

func _connected_fail():
	Log.warning(self, "", "CONNECTION FAILED!")
	get_tree().change_scene(Scene.main_menu)
	self.queue_free()

# The initial loading of all existing entities upon connection.
puppet func initial_client_load_entities(entities_data: Array) -> void:
	for e_data in entities_data:
		var p = EntityData.new().deserialize(e_data)
		self.entities[p.peer_id] = p
	for entity in self.entities.values():
		add_player(entity)
	
	crpc_signal(Signals.Network, Signals.Network.CLIENT_LOAD_FINISHED, self.peer_id)
	Log.trace(self, "", "LOADED ENTITIES %s" %entities)
