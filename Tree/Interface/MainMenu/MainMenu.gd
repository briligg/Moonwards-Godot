extends CanvasLayer
"""
	MainMenu Singleton Scene Script
"""

onready var tabs: TabContainer = $"Top/Tabs"


#Show the main menu.
func show() -> void:
	for i in get_children():
		if i is Control:
			i.visible = true

#Hide the main menu.
func hide() -> void:
	for i in get_children():
		if i is Control:
			i.visible = false

#This is legacy code that was in charge of connecting to the network and 
#giving the network the player's name.
func _on_bJoinServer_pressed() -> void:
	return
#		var player_data = {
#			username = Options.player_data.username,
#			gender = Options.gender,
#			colors = {"pants" : Options.pants_color, "shirt" : Options.shirt_color, "skin" : Options.skin_color, "hair" : Options.hair_color, "shoes" : Options.shoes_color}
#		}
#		Lobby.connect_to_server(player_data, false, "34.70.91.191")

func _on_bLocalGame_pressed() -> void:
	tabs.current_tab = 3

func _on_bAbout_pressed() -> void:
	tabs.current_tab = get_node( "Top/Tabs/About" ).get_position_in_parent()

func _on_bQuit_pressed() -> void:
#	Options.save_user_settings()
	get_tree().quit()

func _on_bStart_pressed():
	#This is a temporary button with temporary code.
	var test_scene = preload("res://_tests/NewDemo/TestScene.tscn")
	get_tree().change_scene_to(test_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
