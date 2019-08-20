extends Control

var SceneOptions : PackedScene = preload("res://assets/UI/Options/Options.tscn")
var SceneMenu : PackedScene = preload("res://assets/UI/Menu/Main_menu.tscn")
var SceneDiagram : PackedScene = preload("res://assets/UI/Diagram.tscn")
var added_menu_ui = false
var diagram_visible = false

func _ready():
	UIManager.RegisterBaseUI(self)

func _input(event):
	if event.is_action_pressed("ui_menu_options"):
		if added_menu_ui:
			UIManager.ClearUI()
			added_menu_ui = false
		elif UIManager.RequestFocus():
			UIManager.NextUI(SceneOptions)
			added_menu_ui = true
	if event.is_action_pressed("ui_cancel"):
		if added_menu_ui:
			UIManager.ClearUI()
			added_menu_ui = false
		elif UIManager.RequestFocus():
			UIManager.NextUI(SceneMenu)
			added_menu_ui = true
	if event.is_action_pressed("show_diagram"):
		if diagram_visible:
			UIManager.ClearUI()
			diagram_visible = false
		elif UIManager.RequestFocus():
			UIManager.NextUI(SceneDiagram)
			diagram_visible = true
