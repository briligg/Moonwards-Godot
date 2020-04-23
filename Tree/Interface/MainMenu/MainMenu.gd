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

func _on_bLocalGame_pressed() -> void:
	Signals.Network.emit_signal(Signals.Network.GAME_SERVER_REQUESTED, true)

func _on_bAbout_pressed() -> void:
	tabs.current_tab = get_node( "Top/Tabs/About" ).get_position_in_parent()

func _on_bQuit_pressed() -> void:
#	Options.save_user_settings()
	get_tree().quit()

func _on_bStart_pressed() -> void:
	#This is a temporary button with temporary code.
	return
#	var test_scene = preload("res://_tests/NewDemo/TestScene.tscn")
#	get_tree().change_scene_to(test_scene)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_bJoinServer_pressed():
	Signals.Network.emit_signal(Signals.Network.GAME_CLIENT_REQUESTED)
