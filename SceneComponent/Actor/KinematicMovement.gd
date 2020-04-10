extends AMovementController
class_name KinematicMovement
# Component for kinematic movement

onready var kb = $KinematicBody

func _init() -> void:
	pass

func _ready() -> void:
	pass

func _physics_process(delta: float):
	#if not is_grounded():
	#move
	pass
