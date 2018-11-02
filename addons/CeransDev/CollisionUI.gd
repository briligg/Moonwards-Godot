extends Control 
const collisions = preload("res://addons/CeransDev/MakeCollisionShapes.gd")
var console

func _enter_tree():
	#var Selected = get_node("CenterContainer/VSplitContainer/VBoxContainer/Create")
	#Selected.connect("pressed", self,"create_selected_only")
	var CreateAll = get_node("CenterContainer/VSplitContainer/VBoxContainer/Createall")
	CreateAll.connect("pressed", self,"create_for_all")
	var DeleteSelected = get_node("CenterContainer/VSplitContainer/VBoxContainer2/Delete")
	DeleteSelected.connect("pressed", self, "delete_selected")
	var DeleteAll = get_node("CenterContainer/VSplitContainer/VBoxContainer2/Deleteall")
	DeleteAll.connect("pressed", self, "delete_all")
	var Test = get_node("CenterContainer/VSplitContainer/VBoxContainer2/Tree")
	Test.connect("pressed", self, "test_Tree")
	console = $CenterContainer/VSplitContainer2/VBoxContainer/Panel/RichTextLabel
	pass
	
	
func create_selected_only():
	console.text = console.text + "Create!"
	$WindowDialog.popup_centered()
	pass
	
func create_for_all():
	pass
	
func delete_selected():
	pass
	
func delete_all():
	pass
	
func test_Tree():
	print("pressed")
	#var Editor = EditorScript.new()
	#var Scene = Editor.get_scene()
	#var col = collisions.new()
	#col.get_all_meshes(Scene)
	#pass

func _on_Create_pressed():
	print("Create!")
