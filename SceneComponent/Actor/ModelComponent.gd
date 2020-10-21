extends AComponent

# Temporary until this is done dynamically.
export (NodePath) var mesh_path : NodePath
onready var mesh: MeshInstance = get_node(mesh_path)

func _init().("ModelComponent", false):
	pass

#func _ready() -> void:
#	set_colors()

func set_colors(colors: Array = []) -> void:
	if colors.size() == 0:
		return
	var count = mesh.get_surface_material_count()
	for i in colors.size():
		var mat = mesh.mesh.surface_get_material(i)
		if mat:
			mat = mat.duplicate()
		else:
			mat = SpatialMaterial.new()
		mat.albedo_color = colors[i]
		mesh.set_surface_material(i, mat)
