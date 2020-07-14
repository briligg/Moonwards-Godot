extends AComponent

func _init().("NametagComponent", false):
	pass
	
func _ready() -> void:
	$Nametag3D.set_name(entity.entity_name)
