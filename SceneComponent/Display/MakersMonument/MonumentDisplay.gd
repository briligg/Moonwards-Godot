tool
extends Spatial

onready var interactable_area: Area = $Interactable

onready var monument_camera: Camera = $InteractionCamera
var player_camera: Camera = null


func _ready():
	interactable_area.connect("interacted_by", self, "_on_interacted_by")


func _input(event):
	# quit
	if event.is_action_pressed("use"):
		self.set_process_input(false)
		$Screen.set_process_input(false)
		
		if(player_camera != null):
			player_camera.make_current()
			player_camera = null
	
		interactable_area.set_collision_layer_bit(15, true)


func _on_interacted_by(_interactor_node):
	self.set_process_input(true)
	$Screen.set_process_input(true)
	
	player_camera = get_viewport().get_camera()
	monument_camera.make_current()
	
	interactable_area.set_collision_layer_bit(15, false)
