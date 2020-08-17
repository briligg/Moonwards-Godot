tool
extends EditorPlugin

var editor = load("res://addons/joyeux_dialog_system/src/editor/editor.tscn").instance()

func _enter_tree():
	add_control_to_bottom_panel(editor, "Dialog Editor")
	pass


func _exit_tree():
	remove_control_from_bottom_panel(editor)
	pass
