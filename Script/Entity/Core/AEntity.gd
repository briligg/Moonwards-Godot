extends MwSpatial
class_name AEntity


export(bool) var enable_on_spawn = false

var enabled = false setget set_enabled

var entity_id: int = -1

var entity_name: String = ""

var components: Dictionary = {}

## Movement Anchoring
var movement_anchor_data = AnchorMovementData.new(self)

func _ready() -> void:
	if enable_on_spawn:
		enabled = true
	add_to_group(Groups.ENTITIES)
	Signals.Entities.emit_signal(Signals.Entities.ENTITY_CREATED, self)
	# Because godot, right?
	set_enabled(enabled)

func add_component(_name: String, _comp: Node) -> void:
	# Add error checking here.
	components[_name] = _comp

func get_component(_name: String) -> Node:
	if components.has(_name):
		return components[_name]
	else:
		return null

#Require that the passed epi name is present in the entity or crash the game.
#If this crashes, it could be that the EPIs node is not present as a child.
func demand_epi(epi_name : String) -> EPIBase :
	assert($EPIs.has_node(epi_name))
	var return_epi : EPIBase = $EPIs.get_node(epi_name)
	return return_epi

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

#Typical way of getting an epi. Return the requested epi if I have it or return a 
#functioning epi that is not used otherwise.
#If this crashes, it could be that the EPIs node is not present as a child.
func request_epi(epi_name : String) -> EPIBase :
	if $EPIs.has_node(epi_name) :
		var return_epi = $EPIs.get_node(epi_name)
		return return_epi
	else :
		return EPIManager.get_dummy_epi(epi_name)

func set_enabled(val: bool) -> void:
	if val:
		enable()
	else:
		disable()
