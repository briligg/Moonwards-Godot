tool
extends EditorScript

func _run():
	var scn = get_scene()
	scn.print_tree_pretty()