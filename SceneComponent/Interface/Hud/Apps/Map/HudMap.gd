extends PanelContainer


func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.MAP_VISIBILITY_SET, self, "_set_active")
	
	#Listen for when hide map is shown.
	var button : Button = $VBoxContainer/HBoxContainer2/HideMapButton
	button.connect("pressed", self, "_set_active", [false])

func _set_active(become_visible : bool) -> void :
	if become_visible :
		get_parent().new_active_app(self)
	else :
		get_parent().revert_active_app()
