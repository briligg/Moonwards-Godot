"""
 The nametag that is above players' heads.
"""
extends MeshInstance


#Only call ready once even if we get moved around the scene tree.
func _init() -> void :
	call_deferred("_ready_once")

#We have to do this in order for all Nametags to properly display the name.
func _ready_once() -> void :
	material_override.albedo_texture = $NametagHolder.get_texture()

func set_name(name: String) -> void:
	$NametagHolder/Username.text = name
