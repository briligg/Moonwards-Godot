extends Spatial


export var required_entity : NodePath 

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

func _relay_interaction(interactor : AEntity) -> void :
	var entity : AEntity = get_node(required_entity)
	
	if entity == interactor && suited_human != null :
		entity.get_node("ControllableBodyComponent").interact_with(suited_human)
		suited_human.enable()
		suited_human.show()
		suited_human = null
	
	elif entity.has_node("ControllableBodyComponent") :
		suited_human = interactor
		entity.get_node("ControllableBodyComponent").interact_with(suited_human)
		
		suited_human.disable()
		suited_human.hide()
	
	else :
		Log.error(self, "_relay_interaction", "%s required entity failed to have the correct node" % get_path())
