extends Area

const DETECTED = "detected"
signal detected()
const DETECTIONS_CEASED = "detections_ceased"
signal detections_ceased()

func _area_entered(_area : Area) -> void :
	#Check if the area is what I am looking for.
	if get_overlapping_areas().size() == 1 :
		emit_signal(DETECTED)

func _area_left(_area : Area) -> void :
	if get_overlapping_areas().empty() :
		emit_signal(DETECTIONS_CEASED)

func _init() -> void :
	collision_mask = 524288
	collision_layer = 0

func _ready() -> void :
	connect("area_entered", self, "_area_entered")
	connect("area_left", self, "_area_left")
