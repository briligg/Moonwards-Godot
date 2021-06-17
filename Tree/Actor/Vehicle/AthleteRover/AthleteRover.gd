extends VehicleEntity

# used by the animation_controller
var wheels: Array = []

func _ready() -> void:
#	temporary hacks to only have certain parts of the rover enabled.
	self.entity_name = self.name
	#This isnt owned until someone rides it
	self.owner_peer_id = -1
	self.set_network_master(1)
	self.enable()
	self.get_component("Camera").camera.current = false
	
	wheels = [
		$left_front_wheel,
		$left_mid_wheel,
		$left_back_wheel,
		$right_front_wheel,
		$right_mid_wheel,
		$right_back_wheel,
	]
