extends AComponent

# Temporary until this is done dynamically.
export (NodePath) var mesh_path : NodePath
onready var mesh: MeshInstance = get_node(mesh_path)

func _init().("ModelComponent", false):
	pass

func set_colors(colors: Array = []) -> void:
	if colors.size() == 0:
		return
	
	#I don't know what the commented out code was used for.
#	var count = mesh.get_surface_material_count()

	for i in range(0,colors.size()) :
		var mat = mesh.mesh.surface_get_material(i)
		if mat:
			mat = mat.duplicate()
		else:
			mat = SpatialMaterial.new()
		mat.albedo_color = colors[i]
		mesh.set_surface_material(i, mat)

#Set this human's gender.
func set_gender(gender : int = 0) -> void :
	if not gender == 0 : #Male player model.
		#Hide female model and show male.
		mesh.hide()
		mesh = mesh.get_parent().get_node("Male_Player_LOD0")
		mesh.show()
