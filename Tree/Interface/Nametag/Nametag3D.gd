"""
 The nametag that is above players' heads.
"""
extends MeshInstance


func _init() -> void :
	call_deferred("_ready_once")

func _ready_once() -> void :
	material_override.albedo_texture = $NametagHolder.get_texture()

func set_name(name: String) -> void:
	$NametagHolder/Username.text = name
