extends LodModel
class_name MultiMeshConverter
### Converts multiple mesh instances to multimeshes at runtime


# Recurse on all child nodes & their children
export(bool) var is_enabled: bool = true
export(bool) var use_recursive: bool = true
export(int) var minimum_instances: int = 2

func _ready() -> void:
	generate_mesh_data(self)
	MultiMeshFactory.generate_multimeshes()
	._ready()

func generate_mesh_data(node, starting_lod_level = "LOD0"):
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
#			var factory_data = MeshFactoryData.new()
#			factory_data.spawn_path = self.get_path()
#			factory_data.mesh = child.mesh
			MultiMeshFactory.add_mesh_data(child.mesh, child,
					child.global_transform, current_lod_level)
#			child.queue_free()
		if use_recursive:
			if child.get_child_count() > 0:
				generate_mesh_data(child, current_lod_level)
