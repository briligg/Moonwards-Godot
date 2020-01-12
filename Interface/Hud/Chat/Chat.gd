extends PanelContainer
"""
	Chat Scene Script
"""

onready var _rtl: RichTextLabel = $"V/RichTextLabel"
onready var _le: LineEdit = $"V/LineEdit"

var _active: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and event.pressed:
			if not _active:
				_le.grab_focus()
				_le.editable = true
				_active = true


func _on_LineEdit_text_entered(new_text: String) -> void:
	if new_text != "":
		rpc("_append_text_to_chat", new_text, get_tree().get_network_unique_id() )
	
	_le.clear()
	_le.release_focus()
	_le.editable = false
	
	set_deferred("_active", false)


remotesync func _append_text_to_chat(new_text: String, talker_id : int) -> void:
	_rtl.newline()
	# TODO: Add timestap prefix
	# TODO: Add serverside logging
	
	#Show the player's name next to their input.
	#warning-ignore:return_value_discarded
	var talker_name : String = GameState.player_get( "username", talker_id )
	_rtl.append_bbcode( "[color=#DB7900]" + talker_name +  ":[/color] " )
	
	#warning-ignore:return_value_discarded
	_rtl.append_bbcode(new_text)
