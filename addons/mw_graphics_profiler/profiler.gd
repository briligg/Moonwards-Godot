tool
extends EditorPlugin

var editor = load("res://addons/mw_graphics_profiler/profiler.tscn").instance()

func _enter_tree():
	add_control_to_bottom_panel(editor, "Graphics Profiler")
	pass


func _exit_tree():
	remove_control_from_bottom_panel(editor)
	pass
