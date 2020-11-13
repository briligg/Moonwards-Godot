extends Control


func hide_panels(_old_app = null, _new_app = null) -> void :
	$MenuPanel.hide_panel()
	$HelpPanel.hide_panel()

func tutorial_menu_active(become_visible : bool) -> void :
	$TutorialMenu.visible = become_visible
	for node in [$HelpPanel] :
		node.visible = !become_visible
	
	#I should be visible no matter what so TutorialMenu can be seen.
	show()
	
	
	
	
