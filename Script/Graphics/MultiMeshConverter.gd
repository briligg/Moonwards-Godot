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
	Log.debug(self, "_ready", "MMC READY!!")
	MultiMeshFactory.connect("meshes_generated", self, "_on_meshes_generated")

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
			# Convert the child's global origin  to local to this node
			# such as it doesn't spawn offset. You can't set MM global origin.
			var xfm = child.global_transform
			xfm.origin = to_local(xfm.origin)
			MultiMeshFactory.add_mesh_data(child.mesh, child,
					xfm, current_lod_level, minimum_count, self.get_path())
		if use_recursive:
			if child.get_child_count() > 0:
				generate_mesh_data(child, current_lod_level)

func _on_meshes_generated():
	._ready_lod()
