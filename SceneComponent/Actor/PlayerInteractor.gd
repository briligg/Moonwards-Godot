extends AComponent

export var user : NodePath = get_path()


#This function is required by AComponent.
func _init().("PlayerInteractor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	$Interactor.user = entity
