extends Button


var is_collapsed : bool = false

func _pressed() -> void :
	#Make it so I rotate perfectly.
	var texture : TextureRect = get_node("../TextureRect")
	texture.rect_pivot_offset = texture.rect_size * 0.5
	
	var dynamic_anim : AnimationPlayer
	dynamic_anim = get_node("../../../../../Anim")
	
	#Play backwards if need be.
	if is_collapsed :
		dynamic_anim.play("show")
	else :
		dynamic_anim.play("hide")
	
	is_collapsed = !is_collapsed
