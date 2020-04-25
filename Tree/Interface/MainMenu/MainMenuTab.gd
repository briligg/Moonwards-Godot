extends TabContainer

"""
 Handle the switching of tabs for the panel.
"""


const START_GAME_TAB : int = 0
const SETTINGS_TAB : int = 1
const OTHER_TAB : int = 2


func _on_StartGame_pressed():
	current_tab = START_GAME_TAB

func _on_Settings_pressed():
	current_tab = SETTINGS_TAB

func _on_Other_pressed():
	current_tab = OTHER_TAB
