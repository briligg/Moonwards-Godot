extends PanelContainer


func controls_pressed() -> void :
	var vbox : VBoxContainer = $VBoxContainer
	vbox.visible = !vbox.visible
	var controls : Tabs = $Controls
	controls.visible = !controls.visible

func hide_panel() -> void :
	hide()

func toggle_menu_panel() -> void :
	visible = !visible
