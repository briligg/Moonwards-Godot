extends Node
# Signal manager, handles the definition &  bouncing of signals between 
# different aspects of the game.

# To add a new signal (ex: Entities.ENTITY_CREATED), 
# or a new signal type (ex: Entities)

# 1. Create a new class in the SignalsManager folder, with the appropriate name.
# 2. Add the signal to it 
# 3. If it's a new signal type class, 
# add a new instance with it's name in this class.

# Refer to "EntitySignals.gd" for reference.

var Entities = EntitySignals.new() setget _set_illegal
var Menus = MenuSignals.new() setget _set_illegal
var Hud = HudSignals.new() setget _set_illegal
var Network = NetworkSignals.new() setget _set_illegal
var Lod = LodSignals.new() setget _set_illegal
var Audio = AudioSignals.new() setget _set_illegal

# These are constant instances and should not be set at all.
func _set_illegal(_val) -> void:
	Log.warning(self, "_set_illegal","Set invocation is illegal")
