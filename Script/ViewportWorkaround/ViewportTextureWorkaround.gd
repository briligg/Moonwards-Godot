extends Viewport


func _ready() -> void :
	call_deferred("_ready_deferred")

func _ready_deferred() -> void :
	get_parent().material_override.albedo_texture = get_texture()
