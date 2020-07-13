extends AComponent

func _init().("SpeedometerComponent", true):
	pass

func _ready():
	if get_tree().network_peer and get_tree().get_network_unique_id() != entity.owner_peer_id:
		$SpeedLbl.visible = false

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	$SpeedLbl.text = "%s km/h" %(get_parent().velocity * 3.6)
