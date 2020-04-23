extends Reference
class_name EntitySignals

### Until we or godot implements proper class_name handling
const name = "Entities"

# Define the signal's string name.
const ENTITY_CREATED: String = "entity_created"

# Define the actual signal.
signal entity_created(entity)
