extends Spatial
class_name AComponent

onready var entity: AEntity = get_parent()
export(bool) var enabled = true setget _set_enabled
export(String) var comp_name = "" setget , _get_comp_name

func _init(_comp_name: String) -> void:
	comp_name = _comp_name

func _ready() -> void:
	entity.add_component(comp_name, self)
	add_to_group(Groups.COMPONENTS)

func _set_enabled(val: bool) -> void:
	Log.trace(self, "set_enabled", "enabled has been set to {enabled}")
	enabled = val

func _get_comp_name() -> String:
	return comp_name


