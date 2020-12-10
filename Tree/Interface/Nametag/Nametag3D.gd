"""
 The nametag that is above players' heads.
"""
extends MeshInstance

func set_name(name: String) -> void:
	$NametagHolder/Username.text = name
