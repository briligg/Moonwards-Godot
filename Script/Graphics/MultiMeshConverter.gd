extends LodModel
class_name MultiMeshConverter
### Converts multiple mesh instances to multimeshes at runtime


# Recurse on all child nodes & their children
export(bool) var is_enabled: bool = true
export(bool) var use_recursive: bool = true
export(int) var minimum_count: int = 3
export(bool) var dbg_generate_on_ready: bool = false

func _ready() -> void:
	generate_mesh_data(self)
	if dbg_generate_on_ready:
		MultiMeshFactory.generate_multimeshes()
#	Log.error(self, "", "MMC READY!!")
	._ready()

func generate_mesh_data(node, starting_lod_level = "NOLOD"):
	if !is_enabled:
		return
	var current_lod_level = starting_lod_level
	var children = node.get_children()
	if children.empty():
		return
	
	for child in children:
		if child.name == "LOD0" || child.name == "LOD1" || child.name == "LOD2":
			current_lod_level = child.name
		if child is MeshInstance:
			MultiMeshFactory.add_mesh_data(child.mesh, child,
					child.global_transform, current_lod_level, minimum_count, self.get_path())
		if use_recursive:
			if child.get_child_count() > 0:
				generate_mesh_data(child, current_lod_level)
