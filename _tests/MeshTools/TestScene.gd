extends Spatial
var MeshTool = preload("res://scripts/MeshTool.gd")
export(NodePath) var test_mesh

func _ready():
	yield(get_tree(), "idle_frame")
	var mt = MeshTool.new(get_tree().current_scene, test_mesh)

	print("hit box: %s, %s" % [test_mesh, mt.get_hitbox()])
