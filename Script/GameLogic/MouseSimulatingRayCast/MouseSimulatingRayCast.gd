extends RayCast
class_name MouseSimulatingRayCast


signal collider_changed(new_collider_node_or_null)

var previous_collider = null


#Determine when I am colliding. If I am, then let Hud know.
func _physics_process(_delta : float) -> void:
	if is_colliding() &&  previous_collider != get_collider():
		if previous_collider != null :
			previous_collider.emit_signal("mouse_exited")
		previous_collider = get_collider()
		previous_collider.emit_signal("mouse_entered")
		emit_signal("collider_changed", previous_collider)
	
	elif not is_colliding() :
		if previous_collider != null :
			previous_collider.emit_signal("mouse_exited")
		previous_collider = null
		emit_signal("collider_changed", null)
