extends Spatial
class_name MultiMeshConverter
### Converts multiple mesh instances to multimeshes at runtime


# Recurse on all child nodes & their children
export(bool) var is_enabled: bool = true
export(bool) var use_recursive: bool = false
export(int) var minimum_instances: int = 4

func _ready() -> void:
	generate_mesh_data(self)
	MultiMeshFactory.generate_multimeshes()

func generate_mesh_data(node):
	if !is_enabled:
		return
		
	var children = node.get_children()
	if children.empty():
		return
		
	for child in children:
		if child is MeshInstance:
#			var factory_data = MeshFactoryData.new()
#			factory_data.spawn_path = self.get_path()
#			factory_data.mesh = child.mesh
			MultiMeshFactory.add_mesh_data(child.mesh.resource_path, child.global_transform)
			child.queue_free()
		if use_recursive:
			if child.get_child_count() > 0:
				generate_mesh_data(child)
