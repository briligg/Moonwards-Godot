extends Spatial


func _init() -> void :
	call_deferred("_ready_deferred")

func _ready_deferred() -> void :
	var texture : ViewportTexture = $Display.get_texture()
	for child in get_children() :
		if child is MeshInstance :
			child.material_override.albedo_texture = texture
