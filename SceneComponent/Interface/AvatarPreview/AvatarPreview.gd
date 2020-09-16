extends Spatial

export(SpatialMaterial) var base_material : SpatialMaterial

onready var avatar_female : Node = get_node("FemalePlayerModel/Female_Player/Skeleton/FemaleBody-LOD0")
onready var avatar_skeleton_female : Node = $FemalePlayerModel/Female_Player/Skeleton
onready var avatar_male : Node = get_node("MalePlayerModel/Male_Player/Skeleton/Male_Player_LOD0")

onready var selected = avatar_female

var _pants_mat : SpatialMaterial
var _shirt_mat : SpatialMaterial
var _skin_mat : SpatialMaterial
var _hair_mat : SpatialMaterial
var _shoes_mat : SpatialMaterial
var _selected_mat : SpatialMaterial = load("res://Tree/Interface/MainMenu/OptionsOld/selected.material")
var _unselected_mat : SpatialMaterial = load("res://Tree/Interface/MainMenu/OptionsOld/unselected.material")

func _ready() -> void:
	_pants_mat = base_material.duplicate()
	_shirt_mat = base_material.duplicate()
	_skin_mat = base_material.duplicate()
	_hair_mat = base_material.duplicate()
	_shoes_mat = base_material.duplicate()
	
	avatar_female.set_surface_material(1, _pants_mat)
	avatar_female.set_surface_material(0, _shirt_mat)
	avatar_female.set_surface_material(2, _skin_mat)
	avatar_female.set_surface_material(4, _hair_mat)
	avatar_female.set_surface_material(3, _shoes_mat)
	
	avatar_male.set_surface_material(2, _pants_mat)
	avatar_male.set_surface_material(3, _shirt_mat)
	avatar_male.set_surface_material(4, _skin_mat)
	avatar_male.set_surface_material(1, _hair_mat)
	avatar_male.set_surface_material(0, _shoes_mat)
	
func clean_selected() -> void:
	selected.set_surface_material(0, _unselected_mat)

func set_selected(_idx : int) -> void:
	selected.set_surface_material(0, _selected_mat)

func set_colors(pants : Color, shirt : Color, skin : Color, hair : Color, shoes : Color) -> void:
	_pants_mat.albedo_color = pants
	_shirt_mat.albedo_color = shirt
	_skin_mat.albedo_color = skin
	_hair_mat.albedo_color = hair
	_shoes_mat.albedo_color = shoes

func set_gender(gender : int) -> void:
	if gender == 0:
		avatar_female.show()
		avatar_male.hide()
		selected = avatar_female
	else:
		avatar_female.hide()
		avatar_male.show()
		selected = avatar_male
