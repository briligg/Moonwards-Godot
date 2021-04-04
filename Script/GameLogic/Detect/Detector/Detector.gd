extends Area
class_name Detector

const DETECTED = "detected"
signal detected()
const DETECTIONS_CEASED = "detections_ceased"
signal detections_ceased()

#If this contains an AEntity, then the only shown detections are of this entity.
var required_entity : AEntity setget set_required_entity

func _area_entered(detectable : Detectable) -> void :
	#Check if the area is what I am looking for.
	if required_entity != null :
		if detectable.get_parent() == required_entity :
			emit_signal(DETECTED)
	
	elif get_overlapping_areas().size() == 1 :
		emit_signal(DETECTED)

func _area_left(detectable : Detectable) -> void :
	if required_entity != null :
		if detectable.get_parent() == required_entity :
			emit_signal(DETECTIONS_CEASED)
	
	elif get_overlapping_areas().empty() :
		emit_signal(DETECTIONS_CEASED)

func _check_detections_helper() -> void :
	var overlap : Array = get_overlapping_areas()
	if not required_entity == null :
		for detectable in overlap :
			if detectable.get_parent() == required_entity :
				emit_signal(DETECTED)
		return
	
	elif get_overlapping_areas().size() > 1 :
		emit_signal(DETECTED)

func _init() -> void :
	collision_mask = 524288
	collision_layer = 0

func _ready() -> void :
	connect("area_entered", self, "_area_entered")
	connect("area_left", self, "_area_left")
	
	call_deferred("_check_detections_helper")

func set_required_entity(aentity : AEntity) -> void :
	required_entity = aentity
