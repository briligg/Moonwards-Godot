extends Control

signal save_scene_pos
signal load_scene_pos
signal lock_all_nodes
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_SaveBtn_pressed():
	emit_signal("save_scene_pos")


func _on_LoadBtn_pressed():
	emit_signal("load_scene_pos")


func _on_LockAllBtn_pressed():
	emit_signal("lock_all_nodes")
