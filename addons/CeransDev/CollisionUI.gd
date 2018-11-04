tool
extends Control 
const collisions = preload("res://addons/CeransDev/MakeCollisionShapes.gd")
var console

func _enter_tree():
	pass

func _on_Create_pressed():
	print("Create!")
	console.text = console.text + "Create!"
	$WindowDialog.popup_centered()

func _on_Createall_pressed():
	pass # Replace with function body.


func _on_Delete_pressed():
	pass # Replace with function body.


func _on_Deleteall_pressed():
	pass # Replace with function body.


func _on_Tree_pressed():
	_run()
	#pass
func _run():
	print("pressed")
	var Editor = EditorScript.new()
	var Scene = Editor.get_scene()
	var col = collisions.new()
	col.get_all_meshes(Scene)