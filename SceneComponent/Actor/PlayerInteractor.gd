extends AComponent

#This function is required by AComponent.
func _init().("PlayerInteractor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	$Interactor.user = entity.get_path()

func _unhandled_input(event : InputEvent) -> void :
	if event.is_action_pressed("use") :
		$Interactor.interact()
