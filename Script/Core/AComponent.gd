extends Spatial
class_name AComponent

onready var entity: Entity = get_parent()
export(bool) var enabled = true setget set_enabled
export(String) var comp_name = "" setget set_comp_name

func _init(_comp_name: String) -> void:
	comp_name = _comp_name

func _ready() -> void:
	entity.add_component(comp_name, self)

func set_enabled(val: bool) -> void:
	Log.trace(self, "set_enabled", "enabled has been set to %enabled" %enabled)
	enabled = val

func set_comp_name(val: String) -> void:
	Log.warning(self, "set_comp_name", "Setting invocation is illegal.")
	assert(false)
