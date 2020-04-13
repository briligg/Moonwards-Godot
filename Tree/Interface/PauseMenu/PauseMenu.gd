extends CanvasLayer
"""
	PauseMenu Singleton Scene Script
"""

onready var tabs: TabContainer = $"Parent/Features"


var _can_open: bool = true
var _open: bool = false


func _ready() -> void:
	#If this crashed, check that the about instanced scene is named About and
	#is a child of Features.
	assert( tabs.has_node( "About" ) )
	#If this crashed, check that their is a control node named Empty 
	#that is a child of Features.
	assert( tabs.has_node( "Empty" ) )
	
	hide(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mainmenu_toggle"):
		#Do nothing if we are not allowed to open.
		if _can_open == false :
			return
		
		if _open:
			hide()
		else:
			show()

func set_openable(state: bool) -> void:
	_can_open = state

func is_open() -> bool:
	return _open

func show() -> void:
	_open = true
	for i in get_children():
		if i is Control:
			i.visible = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide(change_mouse_mode: bool = true) -> void:
	_open = false
	for i in get_children():
		if i is Control:
			i.visible = false
	
	if change_mouse_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_bContinue_pressed() -> void:
	#Hide pause and hide anything that was selected in the pause menu.
	tabs.current_tab = tabs.get_node( "Empty" ).get_position_in_parent()
	hide()

func _on_bOptions_pressed() -> void:
	#Legacy code: Remove when Options.tscn is no longer needed.
	tabs.current_tab = 1

func _on_bAbout_pressed() -> void:
	#Display the about tab or close it if it is already displayed.
	var about_node : PanelContainer = tabs.get_node( "About" )
	if about_node.visible :
		#Hide the about node.
		tabs.current_tab = tabs.get_node( "Empty" ).get_position_in_parent()
	else:
		tabs.current_tab = about_node.get_position_in_parent()

func _on_bQuit_pressed() -> void:
	# TODO: Disconnect from server first
	get_tree().quit()
