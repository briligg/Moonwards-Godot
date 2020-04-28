extends MwSpatial
class_name AComponent

onready var entity: AEntity = get_parent()
export(bool) var enabled = true setget _set_enabled
export(String) var comp_name = "" setget , _get_comp_name
# Whether or not this component must run only on it's owner game client
export(bool) var require_net_owner = false

func _init(_comp_name: String, _req_net_owner: bool) -> void:
	self.comp_name = _comp_name
	self.require_net_owner = _req_net_owner

func _ready() -> void:
	entity.add_component(comp_name, self)
	add_to_group(Groups.COMPONENTS)
	# If we're not owned by this client, we're disabled.
	if get_tree().get_network_unique_id() != entity.owner_peer_id and require_net_owner:
		enabled = false
		set_process(false)
		set_physics_process(false)
		set_process_input(false)

func _process_network(delta) -> void:
	if get_tree().is_network_server() and entity.owner_peer_id == get_tree().get_network_unique_id():
		_process_server(delta)
		_process_client(delta)
	elif get_tree().is_network_server():
		_process_server(delta)
	else:
		_process_client(delta)
		
func _process_server(_delta) -> void:
	pass
	
func _process_client(_delta) -> void:
	pass

func _set_enabled(val: bool) -> void:
	Log.trace(self, "set_enabled", "enabled has been set to {enabled}")
	enabled = val

func _get_comp_name() -> String:
	return comp_name
