extends AComponent

var ride_interactable
func _init().("SpeedometerComponent", true):
	pass

func _ready() -> void:
	ride_interactable = entity.get_component("RoverRideInteractable")
	if get_tree().network_peer and get_tree().get_network_unique_id() != entity.owner_peer_id:
		$SpeedLbl.visible = false

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta: float) -> void:
	$SpeedLbl.text = "%s km/h" %(get_parent().linear_velocity.length() * 3.6)
	if ride_interactable.is_ridable:
		$SpeedLbl.hide()
	elif ride_interactable.controller_peer_id == Network.network_instance.peer_id:
		$SpeedLbl.show()
