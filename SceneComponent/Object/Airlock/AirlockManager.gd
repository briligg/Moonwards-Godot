extends Spatial

#A door that has been requested to close by an entity will make this get emitted when the door is sealed.
signal airlock_sealed()

var open_airlock : AirlockDoorInteractable = null

#Determines when you should wait until the door has finished closing.
var processing_door : bool = false

#Listen for the airlock doors being open or closed.
func _ready() -> void :
	var airlock_array : Array
	airlock_array = [$AirlockDoor_Exterior_LOD0/AirlockDoorInteractable,
	$AirlockDoor_Interior_LOD0/AirlockDoorInteractable]
	
	for airlock in airlock_array :
		airlock.connect("opened", self, "_airlock_opened", [airlock])
		airlock.connect("closed", self, "_airlock_closed")

#Called when something interacts with an open airlock door.
func _airlock_closed() -> void :
	#If a door is processing movement, drop the call.
	if processing_door :
		return
	
	#Close the airlock
	open_airlock.close()
	
	#Wait until the airlock is sealed before opening another airlock.
	processing_door = true
	open_airlock.connect(open_airlock.FINISHED, self, "_airlock_finished_sealing")

#Airlock has finished opening fully.
func _airlock_finished_opening(airlock : AirlockDoorInteractable) -> void :
	processing_door = false
	airlock.disconnect(airlock.FINISHED, self, "_airlock_finished_opening")

#When a player closes a door this function will go off letting us know the door is sealed.
func _airlock_finished_sealing() -> void :
	processing_door = false
	open_airlock.disconnect(open_airlock.FINISHED, self, "_airlock_finished_sealing")
	emit_signal("airlock_sealed")
	open_airlock = null

#Called when something interacts with a closed airlock door.
func _airlock_opened(airlock : AirlockDoorInteractable) -> void :
	#If a door is processing movement, drop the call.
	if processing_door :
		return
	
	#Close the other airlock door if it is open.
	if not open_airlock == null :
		_airlock_closed()
		yield(open_airlock, open_airlock.FINISHED)
	
	#Finally open the requested door.
	open_airlock = airlock
	open_airlock.open()
	
	#Listen for when the door is finished opening.
	processing_door = true
	open_airlock.connect(open_airlock.FINISHED, self, "_airlock_finished_opening", [open_airlock])
