tool
extends EditorPlugin


const MainPanel = preload("res://addons/scene_pos_backup/ui_scene.tscn")

var main_panel_instance
var open_scenes : Array


func _enter_tree():
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func _main_screen_changed(screen_name:String) -> void :
	if screen_name == "Position Backup Tool" :
		main_panel_instance.get_node("RichTextLabel").text = str(open_scenes)


func _ready() -> void :
	#Keep up to date with the open scenes.
	connect("scene_changed", self, "_update_open_scenes_array")
	connect("main_screen_changed", self, "_main_screen_changed")


func _update_open_scenes_array(_scene_root : Node) -> void :
	open_scenes = get_editor_interface().get_open_scenes()


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "Position Backup Tool"


func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("Vector3", "EditorIcons")
