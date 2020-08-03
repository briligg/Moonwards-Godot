tool
extends EditorPlugin

const main_panel = preload("res://addons/joyeux_npc_editor/interface/NPCEditorSuite.tscn")
var main_panel_instance

func _enter_tree():
	main_panel_instance = main_panel.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)

func _exit_tree():
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
