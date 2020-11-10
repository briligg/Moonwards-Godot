extends RayCast
class_name MouseSimulatingRayCast

signal collided(new_collider_node_or_null)

var prev_frame_collider
#Determine when I am colliding. If I am, then let Hud know.
func _physics_process(_delta : float) -> void:
	if is_colliding():
		var collider = get_collider()
		collider.emit_signal("mouse_entered")
		emit_signal("collided", collider)
		prev_frame_collider = collider
	
	elif !is_colliding():
		emit_signal("collided", null)
		if  prev_frame_collider != null:
			prev_frame_collider.emit_signal("mouse_exited")
			prev_frame_collider = null
