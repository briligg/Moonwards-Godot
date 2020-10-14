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
	var state = args[0]
	if process_mode == ProcessMode.IntegrateForces:
		if entity.movement_anchor_data.is_anchored:
			_update_entity_pos()
			
func _integrate_client(state):
	pass

func _process_server(delta: float) -> void:
	if process_mode == ProcessMode.PhysicsProcess:
		if entity.movement_anchor_data.is_anchored:
			_update_entity_pos()

func _update_entity_pos():
	entity.global_transform.origin = entity.movement_anchor_data.get_anchor_position()

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
