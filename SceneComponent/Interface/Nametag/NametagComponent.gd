extends AComponent

func _init().("NametagComponent", false):
	pass
	
func _ready() -> void:
	call_deferred("set_name", entity.entity_name)
	
	#Become visible if I am over another player that is not the local user.
	if not is_net_owner() :
		visible = true
	
func set_name(name) -> void:
	$Nametag3D.set_name(name)
