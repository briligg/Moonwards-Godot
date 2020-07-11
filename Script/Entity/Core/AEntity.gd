extends MwSpatial
class_name AEntity

enum EntityType {
	Undefined,
	Player,
	NPC,
	Vehicle,
	StaticObject,
}

var entity_type = EntityType.Undefined

var enabled = false setget set_enabled

var entity_id: int = -1

var entity_name: String = ""

var components: Dictionary = {}

func _ready():
	add_to_group(Groups.ENTITIES)
	Signals.Entities.emit_signal(Signals.Entities.ENTITY_CREATED, self)
	# Because godot, right?
	set_enabled(enabled)

func add_component(_name: String, _comp: Node) -> void:
	# Add error checking here.
	components[_name] = _comp

func get_component(_name: String) -> Node:
	return components[_name]

func disable() -> void:
	for comp in components.values():
		comp.disable()

func enable() -> void:
	for comp in components.values():
		comp.enable()

func set_enabled(val: bool) -> void:
	if val:
		enable()
	else:
		disable()
	enabled = val
