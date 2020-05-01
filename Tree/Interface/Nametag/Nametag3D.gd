"""
 The nametag that is above players' heads.
"""
extends MeshInstance


#func _init() -> void :
#	var new_material : SpatialMaterial = SpatialMaterial.new()
#	new_material.params_billboard_mode = new_material.BILLBOARD_ENABLED
#	new_material.resource_local_to_scene = true
#	material_override = new_material

func _ready() -> void :
	var new_material : SpatialMaterial = SpatialMaterial.new()
	new_material.params_billboard_mode = new_material.BILLBOARD_ENABLED
	new_material.resource_local_to_scene = true
	new_material.params_cull_mode = new_material.CULL_DISABLED
	new_material.flags_transparent = true
	new_material.flags_unshaded = true
	new_material.flags_fixed_size = true
	material_override = new_material
	
	#Create a material and asign it to myself.
	material_override.albedo_texture = get_node("NametagHolder").get_texture()

func set_name(name: String) -> void:
	$NametagHolder/Username.text = name
