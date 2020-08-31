"""
 The nametag that is above players' heads.
"""
extends MeshInstance


#func _init() -> void :
#	var new_material : SpatialMaterial = SpatialMaterial.new()
#	new_material.params_billboard_mode = new_material.BILLBOARD_ENABLED
#	new_material.resource_local_to_scene = true
#	material_override = new_material

func set_name(name: String) -> void:
	$NametagHolder/Username.text = name
