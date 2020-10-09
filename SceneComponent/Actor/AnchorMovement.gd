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

func _integrate_forces(state):
		invoke_network_based("_integrate_server", "_integrate_client", [state])

func _integrate_server(state) -> void:
	if process_mode == ProcessMode.IntegrateForces:
		if entity.movement_anchor.is_anchored:
			self.global_transform.origin += entity.movement_anchor.movement_delta

func _integrate_client(state):
	pass

func _process_server(delta: float) -> void:
	if process_mode == ProcessMode.PhysicsProcess:
		if entity.movement_anchor.is_anchored:
			self.global_transform.origin += entity.movement_anchor.movement_delta

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
