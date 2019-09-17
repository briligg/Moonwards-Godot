extends Spatial

func print_stats():
	yield(get_tree(), "idle_frame")
	print($TreeStats)
	print("Tree stats:")
	$TreeStats.scene = get_tree().current_scene
	$TreeStats.print_stats()
	
# 	print("lod set:")
# 	print($TreeStats.get_meshlist_lod())
# 	print("lod not set:")
# 	print($TreeStats.get_meshlist_lod(false))
	$MeshTool.root = $TreeStats.scene
	for p in $TreeStats.get_meshlist_lod(false):
		$MeshTool.mesh = p
		print("Mesh(%s) hbox_surface %s" % [
			$MeshTool.id_mesh(),
			$MeshTool.hbox_surface_projection()
			])
	
	print("Tree manager aspect ", $TreeManager.lod_aspect_ratio)
	$TreeManager.enable_managment()
	$TreeStats.print_stats()
	
	for p in $TreeStats.get_meshlist_lod():
		var obj = get_tree().current_scene.get_node(p)
		print ("%s (%s, %s)" % [p, obj.lod_min_distance, obj.lod_max_distance])
	
	$LodManager.enabled = true
# 	print($LodManager.mesh_collection)

func _ready():
	print_stats()

var hide_all = true
func _input(event):
	if event.is_action_pressed("ui_select"):
		print("hide/show all(hide = %s)" % hide_all)
		yield(get_tree(), "idle_frame")
		var root = get_tree().current_scene
		for p in utils.get_nodes_type(root, "MeshInstance", true):
			var obj = root.get_node(p)
			obj.visible = !hide_all
		hide_all = !hide_all
	if event.is_action_pressed("ui_focus_next"):
		$LodManager.enabled = ! $LodManager.enabled
