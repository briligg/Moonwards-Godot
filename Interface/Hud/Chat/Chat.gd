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
		#TODO: Make below method call pass local player's id instead of
		#whole username. We do not want a player that hacked there name
		#to send a rediculously long string and mess up packets for other
		#players. When GameState gets a get_local_player_id is when this
		#todo can be finished.
		rpc("_append_text_to_chat", new_text, Options.username)
	
	_le.clear()
	_le.release_focus()
	_le.editable = false
	
	set_deferred("_active", false)


remotesync func _append_text_to_chat(new_text: String, talkers_name : String) -> void:
	_rtl.newline()
	# TODO: Add timestap prefix
	# TODO: Add serverside logging
	
	#Show the player's name next to their input.
	#warning-ignore:return_value_discarded
	_rtl.append_bbcode( "[color=#DB7900]" + talkers_name +  ":[/color] " )
	
	#warning-ignore:return_value_discarded
	_rtl.append_bbcode(new_text)
