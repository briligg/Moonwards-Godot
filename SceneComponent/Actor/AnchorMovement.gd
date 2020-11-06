extends AComponent
class_name AnchorMovementComponent

enum ProcessMode {
	IntegrateForces,
	PhysicsProcess
}

export(ProcessMode) var process_mode

#This function is required by AComponent.
func _init().("AnchorMovement", false) -> void :
	pass

func _ready():
	self.enabled = true
	entity.connect("on_forces_integrated", self, "_integrate_forces")

func _integrate_forces(args):
		invoke_network_based("_integrate_server", "_integrate_client", [args])

func _integrate_server(args) -> void:
	if process_mode == ProcessMode.IntegrateForces:
		if entity.movement_anchor_data.is_anchored:
			_server_update_entity_values()
			
func _integrate_client(args):
	if process_mode == ProcessMode.IntegrateForces:
		if entity.movement_anchor_data.is_anchored:
			_client_update_entity_values()

func _server_update_entity_values():
	var pos = entity.movement_anchor_data.get_anchor_position()
	entity.global_transform.origin = pos
	entity.srv_pos = pos
		
func _client_update_entity_values():
	# Small hack, to not have to sync anchor state for newly joined players.
	if entity.owner_peer_id == Network.network_instance.peer_id:
		var pos = entity.movement_anchor_data.get_anchor_position()
		entity.global_transform.origin = pos
	else:
		entity.global_transform.origin = entity.srv_pos

func _process_server(delta: float) -> void:
	pass

func _process_client(state):
	pass

# A little hack
# Disable disabling this, it should be globally enabled at all times
func enable():
	self.enabled = true

func disable():
	pass

func set_enabled(val):
	enabled = true
