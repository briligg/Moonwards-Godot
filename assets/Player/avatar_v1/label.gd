extends Label


sync func _process(delta):
	
	var pos = get_node("../TextPoint").to_global(get_node("../TextPoint").translation)
	if (get_viewport().get_camera().is_position_behind( pos )):
		visible = false
	else: 
		show()
	var positione = get_viewport().get_camera().unproject_position(pos) 
	positione = positione -(rect_size*rect_scale/2)
	rect_position = (positione)
	

	#rect_scale = int(3/(camera.translation.distance_to(pos)))*Vector2(1,1)
