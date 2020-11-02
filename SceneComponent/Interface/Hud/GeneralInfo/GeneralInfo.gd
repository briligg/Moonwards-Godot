extends Control


func hide_panels(_old_app = null, _new_app = null) -> void :
	$MenuPanel.hide_panel()
	$HelpPanel.hide_panel()
