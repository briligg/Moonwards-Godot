extends CanvasLayer
"""
	MainMenu Singleton Scene Script
"""

onready var tabs: TabContainer = $"H/T"


func show() -> void:
	for i in get_children():
		if i is Control:
			i.visible = true
	
	PauseMenu.set_openable(false)
	Hud.set_active(false)


func hide() -> void:
	for i in get_children():
		if i is Control:
			i.visible = false
	
	PauseMenu.set_openable(true)
	Hud.set_active(true)

func _on_bJoinServer_pressed() -> void:
		var player_data = {
			username = Options.player_data.username,
			gender = Options.gender,
			colors = {"pants" : Options.pants_color, "shirt" : Options.shirt_color, "skin" : Options.skin_color, "hair" : Options.hair_color, "shoes" : Options.shoes_color}
		}
		Lobby.connect_to_server(player_data, false, "34.70.91.191")

func _on_bLocalGame_pressed() -> void:
	tabs.current_tab = 3


func _on_bOptions_pressed() -> void:
	tabs.current_tab = 1


func _on_bAbout_pressed() -> void:
	tabs.current_tab = 2


func _on_bQuit_pressed() -> void:
	Options.save_user_settings()
	get_tree().quit()
