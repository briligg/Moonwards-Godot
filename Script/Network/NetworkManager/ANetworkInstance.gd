extends Node
class_name ANetworkInstance
# Base class for client and server instances

signal initialized

var is_initialized: bool = false

var world: Node
var entities_container: Node

# Array of EntityData
var entities: Dictionary = {}

var peer_id: int = -1

func _ready() -> void:
	world = yield(Scene.change_scene_to_async(Scene.world_scene), "scene_changed")
	
	world.name = "World"

	entities_container = Node.new()
	entities_container.name = "entities"
	world.add_child(entities_container)
	is_initialized = true
	emit_signal("initialized")

# virtual function called  when `initialized` is fired.
func _start():
	pass

# `PUPPETSYNC`
puppetsync func remove_player(_peer_id: int) -> void:
	if entities.has(_peer_id):
		entities.erase(_peer_id)

	if entities_container.has_node(str(_peer_id)):
		entities_container.get_node(str(_peer_id)).queue_free()

# `PUPPETSYNC`
# Adds a new player to the game
# `entity_data` `EntityData` (or dictionary in serialized form) type
puppetsync func add_player(entity_data) -> void:
	Log.trace(self, "", "ADDING ENTITY %s %s" %[entity_data.peer_id, entity_data.entity_name])
	# Temporary until generic component instancing is available
	if entity_data.is_empty == true:
		var n = Node.new()
		n.name = str(entity_data.peer_id)
		entities_container.add_child(n)
		return
	
	var e = Scene.PLAYER_SCENE.instance()
	e.name = str(entity_data.peer_id)
	e.entity_name = str(entity_data.entity_name)
	e.owner_peer_id = entity_data.peer_id
	e.set_network_master(1)
	entities_container.add_child(e)
	e.enable_on_owner()
	e.global_transform.origin = entity_data.initial_pos
	var model = e.get_component("ModelComponent")
	model.set_gender(entity_data.gender)
	model.set_colors(entity_data.colors)
	
### Networking API
## See if we can move this to it's own script.

# Controlled RPC Wrapper with added control.
func crpc(caller: Node, method: String, args = [], exclude_list: Array = []):
	for client in entities.values():
		if not exclude_list.has(client.peer_id):
			caller.rpc_id(client.peer_id, method, args)

# Controlled RPC Wrapper with added control.
func crpc_unreliable(caller: Node, method: String, args = [], exclude_list: Array = []):
	for client in entities.values():
		if not exclude_list.has(client.peer_id):
			caller.rpc_unreliable_id(client.peer_id, method, args)

# Controlled RSET Wrapper with added control.
func crset(caller: Node, method: String, args = [], exclude_list: Array = []):
	for client in entities.values():
		if not exclude_list.has(client.peer_id):
			caller.rset_id(client.peer_id, method, args)

# Controlled RSET Wrapper with added control.
func crset_unreliable(caller: Node, method: String, args = [], exclude_list: Array = []):
	for client in entities.values():
		if not exclude_list.has(client.peer_id):
			caller.rset_id(client.peer_id, method, args)

### Figure out a better way to handle this, if godot allows
func crpc_signal(instance: Object, sig_name: String, param = null):
	if get_tree().is_network_server():
		crpc(self, "_client_crpc_signal", [instance.name, sig_name, param], [1])
	else:
		rpc_id(1, "_server_crpc_signal",  [instance.name, sig_name, param])

### Figure out a better way to handle this, if godot allows
# `MASTER`
master func _server_crpc_signal(params: Array):
	Log.trace(self, "crpc_signal", "Received server signal crpc: %s" %[params])
	Signals.get(str(params[0])).emit_signal(params[1], params[2])

### Figure out a better way to handle this, if godot allows
#`PUPPET`
puppet func _client_crpc_signal(params: Array):
	Log.trace(self, "crpc_signal", "Received client signal crpc: %s" %[params])
	# Exit if not sent by the server
	if get_tree().get_rpc_sender_id() != 1:
		return
		
	Log.trace(self, "", "Received RPC signal - params: %s" % [params])
	Signals.get(str(params[0])).emit_signal(params[1], params[2])
