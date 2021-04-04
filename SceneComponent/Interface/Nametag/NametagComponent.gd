extends AComponent


func _init().("NametagComponent", false):
	pass
	
func _ready() -> void:
	call_deferred("set_name", entity.entity_name)
	
	#Only be visible if I am not over the main player
	if is_net_owner() :
		visible = false
	
func set_name(name) -> void:
	$Nametag3D.set_name(name)
