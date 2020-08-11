extends TabContainer

"""
 Handle the switching of tabs for the panel.
"""


const DESTINATION_TAB : int = 0
const AVATAR_TAB : int = 1
const NPC_TAB : int = 2
const OTHER_TAB : int = 3


func _on_StartGame_pressed():
	current_tab = DESTINATION_TAB

func _on_Other_pressed():
	current_tab = OTHER_TAB

func _on_Avatar_pressed():
	current_tab = AVATAR_TAB



