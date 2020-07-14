extends Node
class_name MwNode

var owner_peer_id: int = -1

func _physics_process(delta: float) -> void:
	_process_network(delta)

func _process_network(delta: float) -> void:
	if is_network_master():
		_process_server(delta)
	else:
		_process_client(delta)
		
func _process_server(_delta: float) -> void:
	pass
	
func _process_client(_delta: float) -> void:
	pass

# Controlled RPC Wrapper with added control.
func crpc(method: String, val, exclude_list: Array = []):
	if Network.network_instance == null:
		return
	Network.network_instance.crpc(self, method, val, exclude_list)

# Controlled RPC Wrapper with added control.
func crpc_unreliable(method: String, val, exclude_list: Array = []):
	if Network.network_instance == null:
		return
	Network.network_instance.crpc_unreliable(self, method, val, exclude_list)

# Controlled RSET Wrapper with added control.
func crset(method: String, val, exclude_list: Array = []):
	if Network.network_instance == null:
		return
	Network.network_instance.crset(self, method, val, exclude_list)

# Controlled RSET Wrapper with added control.
func crset_unreliable(method: String, val, exclude_list: Array = []):
	if Network.network_instance == null:
		return
	Network.network_instance.crset_unreliable(self, method, val, exclude_list)
