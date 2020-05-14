extends AComponent

# Temporary until this is done dynamically.
export (NodePath) var mesh_path : NodePath
onready var mesh: MeshInstance = get_node(mesh_path)
onready var animation: AnimationPlayer = $AnimationPlayer

func _init().("ModelComponent", false):
	pass

func _ready():
	var count = mesh.get_surface_material_count()
	for i in range(count):
		var mat = mesh.get_surface_material(i).duplicate()
		mesh.set_surface_material(i, mat)

func set_colors(colors: Array) -> void:
	if colors.size() == 0:
		return
		
	var count = mesh.get_surface_material_count()
	for i in range(count):
		var mat = mesh.get_surface_material(i)
		mat.albedo_color = colors[i]
		mesh.set_surface_material(i, mat)
