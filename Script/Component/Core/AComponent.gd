extends MwSpatial
class_name AComponent

onready var entity: AEntity = get_parent()
export(bool) var enabled setget set_enabled
export(String) var comp_name = "" setget , _get_comp_name
# Whether or not this component must run only on it's owner game client
export(bool) var require_net_owner = false

func _init(_comp_name: String, _req_net_owner: bool) -> void:
	self.comp_name = _comp_name
	self.require_net_owner = _req_net_owner

func _ready() -> void:
	entity.add_component(comp_name, self)
	add_to_group(Groups.COMPONENTS)
	# If there's no network peer (local testing)
	if !get_tree().network_peer:
		return
	#TODO: Remove this & refactor parts that may depend on it.
	if !is_net_owner() and require_net_owner:
		disable()

func disable() -> void:
	enabled = false
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	Log.trace(self, "disable", "Component %s has been disabled" %comp_name)
	
# Enables the entity on the owning client
func enable_on_owner():
	if !is_net_owner() and require_net_owner:
		disable()
	else:
		enable()
	
func enable() -> void:
	enabled = true
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	Log.trace(self, "enable", "Component %s has been enabled" %comp_name)

func invoke_network_based(server_func: String, client_func: String, args):
	if !get_tree().network_peer:
		return
	if get_tree().is_network_server() and entity.owner_peer_id == get_tree().get_network_unique_id():
		call(server_func, args)
		call(client_func, args)
	elif get_tree().is_network_server():
		call(server_func, args)
	else:
		call(client_func, args)

func _process_network(delta) -> void:
	if !get_tree().network_peer:
		return
	if get_tree().is_network_server() and entity.owner_peer_id == get_tree().get_network_unique_id():
		_process_server(delta)
		_process_client(delta)
	elif get_tree().is_network_server():
		_process_server(delta)
	else:
		_process_client(delta)
		
func _process_server(_delta: float) -> void:
	pass
	
func _process_client(_delta: float) -> void:
	pass

func set_enabled(val: bool) -> void:
	
	if val == false:
		disable()
	elif val == true:
		enable()

func _get_comp_name() -> String:
	return comp_name

func is_net_owner() -> bool:
	return Network.network_instance.peer_id == entity.owner_peer_id
