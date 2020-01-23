extends PanelContainer
"""
	Chat Scene Script
"""

onready var _chat_display_node: RichTextLabel = $"V/RichTextLabel"
onready var _chat_input_node: LineEdit = $"V/LineEdit"

var _active: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and event.pressed:
			if not _active:
				_chat_input_node.grab_focus()
				_chat_input_node.editable = true
				_active = true


func _on_LineEdit_text_entered(new_text: String) -> void:
	if new_text != "":
		rpc("_append_text_to_chat", new_text, get_tree().get_network_unique_id() )
	
	_chat_input_node.clear()
	_chat_input_node.release_focus()
	_chat_input_node.editable = false
	
	set_deferred("_active", false)


remotesync func _append_text_to_chat(new_text: String, talker_id : int) -> void:
	_chat_display_node.newline()
	# TODO: Add timestap prefix
	# TODO: Add serverside logging
	
	#Show the player's name next to their input.
	#warning-ignore:return_value_discarded
	var talker_name : String = GameState.player_get( "username", talker_id )
	_chat_display_node.append_bbcode( "[color=#DB7900]" + talker_name +  ":[/color] " )
	
	#warning-ignore:return_value_discarded
	_chat_display_node.append_bbcode(new_text)
