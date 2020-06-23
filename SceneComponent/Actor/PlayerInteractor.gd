extends AComponent

#This function is required by AComponent.
func _init().("PlayerInteractor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	$Interactor.user = entity.get_path()
	
	#Listen for when interactions are possible and when they become impossible.
	$Interactor.connect("interact_possible", self, "interact_possible")
	$Interactor.connect("interact_became_impossible", self, "interact_impossible")

func _unhandled_input(event : InputEvent) -> void :
	if event.is_action_pressed("use") :
		$Interactor.interact()

func interact_impossible() -> void :
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_BECAME_IMPOSSIBLE)

func interact_possible(interact_info : String) -> void :
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_POSSIBLE, interact_info)



