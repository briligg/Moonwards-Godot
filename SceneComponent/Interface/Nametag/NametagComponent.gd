extends AComponent

func _init().("NametagComponent", false):
	pass
	
func _ready() -> void:
	set_name(entity.entity_name)
	
func set_name(name) -> void:
	$Nametag3D.set_name(name)
