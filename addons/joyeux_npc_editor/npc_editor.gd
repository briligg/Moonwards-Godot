tool
extends EditorPlugin

const main_panel = preload("res://addons/joyeux_npc_editor/src/interface/NPCEditorSuite.tscn")
var main_panel_instance

func _enter_tree():
	add_autoload_singleton("Nodes", "res://addons/joyeux_npc_editor/src/Core/Nodes.gd")
	main_panel_instance = main_panel.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)

func _exit_tree():
	remove_autoload_singleton("Nodes")
	if main_panel_instance:
		main_panel_instance.queue_free()
	pass

func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible

func has_main_screen():
	return true
func get_plugin_name():
	return "NPC Editor"
