extends Spatial

var open_airlock : AirlockDoorInteractable = null

#Listen for the airlock doors being open or closed.
func _ready() -> void :
	var airlock_array : Array
	airlock_array = [$AirlockDoor_Exterior_LOD0/AirlockDoorInteractable,
	$AirlockDoor_Interior_LOD0/AirlockDoorInteractable2]
	
	for airlock in airlock_array :
		airlock.connect("opened", self, "_airlock_opened", [airlock])
		airlock.connect("closed", self, "_airlock_closed")

#Called when something interacts with an open airlock door.
func _airlock_closed() -> void :
	open_airlock = null

#Called when something interacts with a closed airlock door.
func _airlock_opened(airlock : AirlockDoorInteractable) -> void :
	#Don't do anything if the airlock is already being opened.
	if airlock == open_airlock :
		return
	
	#Close the other airlock door if it is open.
	if not open_airlock == null :
		open_airlock.close()
		yield(open_airlock, "sealed")
	
	open_airlock = airlock
	open_airlock.open()
