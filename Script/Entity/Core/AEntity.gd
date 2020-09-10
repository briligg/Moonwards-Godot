extends MwSpatial
class_name AEntity

enum EntityType {
	Undefined,
	Player,
	NPC,
	Vehicle,
	StaticObject,
}

export(bool) var enable_on_spawn = false

var entity_type = EntityType.Undefined

var enabled = false setget set_enabled

var entity_id: int = -1

var entity_name: String = ""

var components: Dictionary = {}

func _ready() -> void:
	if enable_on_spawn:
		enabled = true
	add_to_group(Groups.ENTITIES)
	Signals.Entities.emit_signal(Signals.Entities.ENTITY_CREATED, self)
	# Because godot, right?
	set_enabled(true)

func add_component(_name: String, _comp: Node) -> void:
	# Add error checking here.
	components[_name] = _comp

func get_component(_name: String) -> Node:
	return components[_name]

func disable() -> void:
	for comp in components.values():
		comp.disable()
	Log.trace(self, "disable", "Entity id:%s, name:%s has been disabled" 
			%[entity_id, entity_name])
	enabled = false
	
func enable() -> void:
	for comp in components.values():
		comp.enable()
	Log.trace(self, "enable", "Entity id:%s, name:%s has been enabled" 
			%[entity_id, entity_name])
	enabled = true

func enable_on_owner() -> void:
	for comp in components.values():
		comp.enable_on_owner()
	Log.trace(self, "enable_on_owner", "Entity id:%s, name:%s has been enabled on owner" 
			%[entity_id, entity_name])
	enabled = true

func set_enabled(val: bool) -> void:
	if val:
		enable()
	else:
		disable()
