extends AComponent

# Temporary until this is done dynamically.
onready var mesh: MeshInstance = $FemaleRig/Skeleton/AvatarFemale.mesh
onready var animation: AnimationPlayer = $AnimationPlayer

func _init().("ModelComponent", false):
	pass

func set_colors(colors: Array) -> void:
	var count = mesh.get_surface_count()
	for i in range(count):
		var mat = mesh.surface_get_material(i)
		mat.albedo_color = colors[i]
		mesh.surface_set_material(i, mat)
