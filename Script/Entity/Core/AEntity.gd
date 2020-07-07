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

var enabled = false

var entity_id: int = -1

var entity_name: String = ""

var components: Dictionary = {}

func _ready():
	add_to_group(Groups.ENTITIES)
	Signals.Entities.emit_signal(Signals.Entities.ENTITY_CREATED, self)
	if enabled:
		enable()
	elif !enabled:
		disable()

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
