extends CanvasLayer
"""
	MainMenu Singleton Scene Script
"""

#Const variable nodes.
onready var CUSTOM_SERVER_ADDRESS_FIELD : TextEdit = get_node( "HBoxContainer/Panel/Tab/DestinationTab/StartGame/InputServer/Ipv4Address") setget _crash


#warning-ignore:unused_argument
func _crash(value) -> void :
	#Do not set the constant node variables.
	assert(true == false)

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

func _quit_pressed() -> void:
#	Options.save_user_settings()
	get_tree().quit()

#Toggle the About scene.
func _on_About_pressed():
	var about : PanelContainer = get_node("HBoxContainer/About")
	var panel : PanelContainer = get_node("HBoxContainer/Panel")
	var v_box : VBoxContainer = get_node("HBoxContainer/VBoxContainer")
	var about_button : Button = get_node("About")
	
	if about.visible:
		about.hide()
		panel.show()
		v_box.show()
		about_button.text = "About"
	
	else:
		panel.hide()
		v_box.hide()
		about.show()
		about_button.text = "Hide About"

#func _on_JoinMainServer_pressed():
	# Until we have config files
#	_on_JoinServer_pressed()

#func _on_StartCustomServer_pressed():
#	Signals.Network.emit_signal(Signals.Network.GAME_SERVER_REQUESTED, 5000)

#func _on_JoinServer_pressed():
#	var ipv4_address : String = CUSTOM_SERVER_ADDRESS_FIELD.text
#	Signals.Network.emit_signal(Signals.Network.GAME_CLIENT_REQUESTED, ipv4_address, 5000)
