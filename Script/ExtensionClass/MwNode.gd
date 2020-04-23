extends Node
class_name MwNode

func _physics_process(delta):
	_process_network(delta)

func _process_network(delta) -> void:
	if is_network_master():
		_process_server(delta)
	else:
		_process_client(delta)
		
func _process_server(_delta) -> void:
	pass
	
func _process_client(_delta) -> void:
	pass

# Controlled RPC Wrapper with added control.
func crpc(method: String, val):
	if Network.network_instance == null:
		return
	Network.network_instance.crpc(self, method, val)

# Controlled RPC Wrapper with added control.
func crpc_unreliable(method: String, val):
	if Network.network_instance == null:
		return
	Network.network_instance.crpc_unreliable(self, method, val)

# Controlled RSET Wrapper with added control.
func crset(method: String, val):
	if Network.network_instance == null:
		return
	Network.network_instance.crset(self, method, val)

# Controlled RSET Wrapper with added control.

func crset_unreliable(method: String, val):
	if Network.network_instance == null:
		return
	Network.network_instance.crset_unreliable(self, method, val)
