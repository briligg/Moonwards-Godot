extends AnimationPlayer

const IDLE_ANIM : String = "Idle"
const INTERACTED_WITH_ANIM : String = "Interacted With"


func _ready() -> void :
	play(IDLE_ANIM)

func _interacted_with(_interactor_ray_cast):
	seek(0)
	play(INTERACTED_WITH_ANIM)
	
	#Listen for when the animation finishes so that I can 
	#start the idle animation again.
	if is_connected("animation_finished", self, "_interacted_with_finished") == false :
		connect("animation_finished", self, "_interacted_with_finished")

func _interacted_with_finished(_anim_name : String) -> void :
	#Stop listening for the animations to finish
	disconnect("animation_finished", self, "_interacted_with_finished")
	
	seek(0)
	play(IDLE_ANIM)
