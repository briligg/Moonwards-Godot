tool
extends EditorPlugin


const MainPanel = preload("res://addons/moonwards_plugin_tests/main_panel.tscn")

var main_panel
var open_scene

func _ready() -> void :
	#Keep up to date with the open scenes.
	connect("scene_changed", self, "_on_scene_changed")
	connect("main_screen_changed", self, "_main_screen_changed")
	main_panel.connect("save_scene_pos", self, "_save_scene_pos")
	main_panel.connect("load_scene_pos", self, "_load_scene_pos")
	main_panel.connect("lock_all_nodes", self, "_lock_all_nodes")

func _enter_tree():
	main_panel = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel)
	# Hide the main panel. Very much required.
	var btn = load("res://addons/moonwards_plugin_tests/test_btn.tscn")
	add_control_to_bottom_panel(btn.instance(), "Bottom Panel")
	add_control_to_container(CONTAINER_TOOLBAR, btn.instance())
	add_control_to_container(CONTAINER_CANVAS_EDITOR_BOTTOM, btn.instance())
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, btn.instance())
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, btn.instance())
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, btn.instance())
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM, btn.instance())
	add_control_to_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT, btn.instance())
	add_control_to_container(CONTAINER_PROPERTY_EDITOR_BOTTOM, btn.instance())
	add_control_to_container(CONTAINER_PROJECT_SETTING_TAB_LEFT, btn.instance())
	add_control_to_dock(DOCK_SLOT_LEFT_UL, btn.instance())
	make_visible(false)

func _exit_tree():
	if main_panel:
		main_panel.queue_free()

func _main_screen_changed(screen_name:String) -> void :
#	if screen_name == "Moonwards Tools" :
#		main_panel.get_node("RichTextLabel").text = str(open_scenes)
	pass

func _on_scene_changed(scene: Node) -> void :
	open_scene = scene
	if scene == null:
		return

	print("SCENE OPENED:%s " %scene.name)
#	open_scenes[scene.name] = scene
#	print(open_scenes)

func has_main_screen():
	return true


func make_visible(visible):
	if main_panel:
		main_panel.visible = visible


func get_plugin_name():
	return "Moonwards Test Screen"


func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("GDScript", "EditorIcons")

func _save_scene_pos():
	print("saved")

func _load_scene_pos():
	print("loaded")
