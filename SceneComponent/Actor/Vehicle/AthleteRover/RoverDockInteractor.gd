extends AComponent

var interactee
var interactee_cam

var is_active = false

func _init().("RoverDock", true):
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	$Interactor.connect("interact_made_possible", self, "interacted_by")
	$Interactor.connect("interacted_with", self, "interacted_by")
	
func interacted_by(e) -> void:
	if !self.is_active:
		self.interactee = e
		self.interactee_cam = interactee.get_component("Camera").camera
		self.interactee.disable()
		self.entity.enable()
		var cam = entity.get_component("Camera")
		if cam:
			cam.camera.current = true
		is_active = true

func disable():
	pass

func return_control() -> void:
	self.interactee.enable()
	self.interactee_cam.current = true
	self.entity.disable()
	self.is_active = false

func _input(event : InputEvent) -> void :
	if event.is_action_pressed("use") and is_active:
		call_deferred("return_control")
