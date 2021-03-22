extends Spatial


export var required_entity : NodePath 
export var prop_path : NodePath = "../Spacesuit_Prop"

#The player currently inside the suit.
var suited_human : AEntity

onready var interactable : Interactable = $Interactable


func _detected() -> void :
	interactable.set_active(true)

func _detections_ceased() -> void :
	interactable.set_active(false)

func _ready() :
	var detector : Area = $Detector
	detector.connect(detector.DETECTIONS_CEASED, self, "_detections_ceased")
	detector.connect(detector.DETECTED, self, "_detected")
	
	detector.set_required_entity(get_node(required_entity))
	
	var interact : Interactable = $Interactable
	interact.connect("interacted_by", self, "_relay_interaction")
	
	#Listen to the spacesuit for when the entity removes control.
	var comp = $Spacesuit/ControllableBodyComponent
	comp.connect(comp.CONTROL_LOST, self, "_suit_control_lost", [comp])
	comp.connect(comp.CONTROL_TAKEN, self, "_suit_control_taken")

func _relay_interaction(interactor : AEntity) -> void :
	var entity : AEntity = get_node(required_entity)
	
	#Return control to the human that started me.
	if entity == interactor && suited_human != null :
		entity.get_node("ControllableBodyComponent").interact_with(suited_human)
		suited_human.enable()
		suited_human.show()
		suited_human = null
		#Suit_control_lost will get called as well.
		
		$Display.hide()
		$Anim.stop()
	
	#Do nothing if the interactor is another spacesuit.
	elif interactor.has_node("ControllableBodyComponent") :
		return
	
	#Take control of a spacesuit. Make sure that the interactor is a human.
	elif entity.has_node("ControllableBodyComponent") :
		suited_human = interactor
		entity.get_node("ControllableBodyComponent").interact_with(suited_human)
		
		suited_human.disable()
		suited_human.hide()
		
		#Allow the spacesuit to move around.
		entity.mode = RigidBody.MODE_CHARACTER
		
		$Display.show()
		$Anim.play("Idle")
	
	else :
		Log.error(self, "_relay_interaction", "%s required entity failed to have the correct node" % get_path())

#Called from a signal.
func _suit_control_lost(component) -> void :
	component.get_parent().global_transform.origin = global_transform.origin
	component.get_parent().rotation_degrees = Vector3.ZERO
	component.get_parent().rset("look_dir", Vector3.FORWARD)
	component.get_parent().rset_id(1, "mlook_dir", Vector3.FORWARD)
	
	var my_entity : AEntity = get_node(required_entity)
	my_entity.mode = RigidBody.MODE_KINEMATIC
	
	#Show the prop again.
	my_entity.hide()
	get_node(prop_path).show()

func _suit_control_taken(_interactor : AEntity) -> void :
	var my_entity : AEntity = get_node(required_entity)
	my_entity.mode = RigidBody.MODE_CHARACTER
	
	get_node(required_entity).show()
	get_node(prop_path).hide()




