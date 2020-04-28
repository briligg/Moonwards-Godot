extends AComponent

# Temporarily until SceneManager, scene indexing & dynamic component creation is added.
onready var model = $Model
onready var animation = $Model/AnimationPlayer

func _init().("AnimationController", false):
	pass

func _process_client(_delta):
	if Helpers.Enum.has_flag(entity.state.state, ActorEntityState.State.IDLE):
		animation.play("CasualStance1")
	elif Helpers.Enum.has_flag(entity.state.state, ActorEntityState.State.MOVING):
		animation.play("Female_MoonWalking-loop")
	elif Helpers.Enum.has_flag(entity.state.state, ActorEntityState.State.IN_AIR):
		animation.play("Flail-loop")
