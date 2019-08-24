extends Control

var SceneOptions = "res://assets/UI/Menu/Options.tscn"
var SceneMenu = "res://assets/UI/Menu/Main_menu.tscn"
var SceneDiagram = "res://assets/UI/Diagram.tscn"
var Options = null
var added_menu_ui = false
var diagram_visible = false

func _ready():
	UIManager.register_base_ui(self)

func _input(event):
	if event.is_action_pressed("ui_menu_options"):
		if added_menu_ui:
			UIManager.clear_ui()
			added_menu_ui = false
		elif UIManager.request_focus():
			UIManager.next_ui(SceneOptions)
			added_menu_ui = true
	if event.is_action_pressed("ui_cancel"):
		if added_menu_ui:
			UIManager.clear_ui()
			added_menu_ui = false
		elif UIManager.request_focus():
			UIManager.next_ui(SceneMenu)
			added_menu_ui = true
	if event.is_action_pressed("show_diagram"):
		if diagram_visible:
			UIManager.clear_ui()
			diagram_visible = false
		elif UIManager.request_focus():
			UIManager.next_ui(SceneDiagram)
			diagram_visible = true

func OptionsPanel():
		if Options:
			options.set("_state_", Options.get_tab_index(), "menu_options_tab")
			Options.queue_free()
			Options = null
			options.save()
			Input.set_mouse_mode(options.get("_state_", "menu_options_mm", Input.MOUSE_MODE_VISIBLE))
		else:
			Options = ResourceLoader.load(SceneOptions).instance()
			Options.signal_close = true
			Options.connect("close", self, "OptionsPanel")
			Options.set_tab_index(options.get("_state_", "menu_options_tab", 1))
			get_tree().get_root().add_child(Options)
			options.set("_state_", Input.get_mouse_mode(), "menu_options_mm")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
