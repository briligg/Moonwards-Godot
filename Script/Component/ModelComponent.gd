extends AComponent

# Temporary until this is done dynamically.
onready var mesh_inst: MeshInstance = $FemaleRig/Skeleton/AvatarFemale
onready var animation: AnimationPlayer = $AnimationPlayer

func _init().("ModelComponent", false):
	pass

func _ready():
	var count = mesh_inst.mesh.get_surface_count()
	for i in range(count):
		var mat = mesh_inst.mesh.surface_get_material(i).duplicate()
		mesh_inst.set_surface_material(i, mat)

func set_colors(colors: Array) -> void:
	if colors.size() == 0:
		return
		
	var count = mesh_inst.get_surface_material_count()
	for i in range(count):
		var mat = mesh_inst.get_surface_material(i)
		mat.albedo_color = colors[i]
		mesh_inst.set_surface_material(i, mat)
