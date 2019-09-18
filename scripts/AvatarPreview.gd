extends Spatial

export(SpatialMaterial) var base_material : SpatialMaterial

var _pants_mat : SpatialMaterial
var _shirt_mat : SpatialMaterial
var _skin_mat : SpatialMaterial
var _hair_mat : SpatialMaterial
var _shoes_mat : SpatialMaterial
var _selected_mat : SpatialMaterial = load("res://assets/UI/Options/selected.material")
var _unselected_mat : SpatialMaterial = load("res://assets/UI/Options/unselected.material")

func _ready() -> void:
	_pants_mat = base_material.duplicate()
	_shirt_mat = base_material.duplicate()
	_skin_mat = base_material.duplicate()
	_hair_mat = base_material.duplicate()
	_shoes_mat = base_material.duplicate()
	
	$AvatarRig/FemaleRig/Skeleton/AvatarFemale.set_surface_material(1, _pants_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarFemale.set_surface_material(0, _shirt_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarFemale.set_surface_material(2, _skin_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarFemale.set_surface_material(4, _hair_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarFemale.set_surface_material(3, _shoes_mat)
	
	$AvatarRig/FemaleRig/Skeleton/AvatarMale.set_surface_material(2, _pants_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarMale.set_surface_material(3, _shirt_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarMale.set_surface_material(4, _skin_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarMale.set_surface_material(1, _hair_mat)
	$AvatarRig/FemaleRig/Skeleton/AvatarMale.set_surface_material(0, _shoes_mat)
	
func clean_selected() -> void:
	for genders in $AvatarRig/FemaleRig/Skeleton.get_children():
		for selector in genders.get_children():
			selector.set_surface_material(0, _unselected_mat)

func set_selected(idx : int) -> void:
	for genders in $AvatarRig/FemaleRig/Skeleton.get_children():
		genders.get_child(idx).set_surface_material(0, _selected_mat)

func set_colors(pants : Color, shirt : Color, skin : Color, hair : Color, shoes : Color) -> void:
	_pants_mat.albedo_color = pants
	_shirt_mat.albedo_color = shirt
	_skin_mat.albedo_color = skin
	_hair_mat.albedo_color = hair
	_shoes_mat.albedo_color = shoes

func set_gender(gender : int) -> void:
	if gender == 0:
		$AvatarRig/FemaleRig/Skeleton/AvatarFemale.show()
		$AvatarRig/FemaleRig/Skeleton/AvatarMale.hide()
	else:
		$AvatarRig/FemaleRig/Skeleton/AvatarFemale.hide()
		$AvatarRig/FemaleRig/Skeleton/AvatarMale.show()