extends TextureRect


var camera : Camera

onready var ray_cast : RayCast = get_node("ReticleRayCast")


func _physics_process(_delta) -> void :
	var current_camera : Camera = get_tree().root.get_camera()
	if current_camera != camera :
		camera = current_camera
		ray_cast.get_parent().remove_child(ray_cast)
		current_camera.add_child(ray_cast)

#Listen to SignalsManager to see when I should activate/deactivate.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.RETICLE_ACTIVITY_SET, self, "_set_activity")

#Determines if I should turn on when requested or not.
func _set_activity(is_active : bool) -> void :
	if is_active :
		Signals.Hud.connect(Signals.Hud.SHOW_RETICLE, self, "show")
		Signals.Hud.connect(Signals.Hud.HIDE_RETICLE, self, "hide")
	else :
		hide()
		Signals.Hud.disconnect(Signals.Hud.SHOW_RETICLE, self, "show")
		Signals.Hud.disconnect(Signals.Hud.HIDE_RETICLE, self, "hide")
