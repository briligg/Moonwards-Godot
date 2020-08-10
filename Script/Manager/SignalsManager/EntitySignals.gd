extends Reference
class_name EntitySignals

### Until we or godot implements proper class_name handling
const name = "Entities"

# Define the signal's string name.
const ENTITY_CREATED: String = "entity_created"
const FLY_TOGGLED : String = "fly_toggled"


# Define the actual signal.
signal entity_created(entity)
signal fly_toggled()
