extends AComponent

var last_pos: Vector3 = Vector3.ZERO

export(float) var lod0_max_distance: float = 5 setget _set_lod0_dist
export(float) var lod1_max_distance: float = 10 setget _set_lod1_dist

onready var lod0: Area = $LOD0Area
onready var lod1: Area = $LOD1Area

func _init().("LodComponent", true):
	pass

func _ready():
	lod0.get_node("CollisionShape").scale *= lod0_max_distance
	lod1.get_node("CollisionShape").scale *= lod1_max_distance
	
	lod0.connect("area_entered", self, "_on_lod0_entered")
	lod0.connect("area_exited", self, "_on_lod0_exited")
	lod1.connect("area_entered", self, "_on_lod1_entered")
	lod1.connect("area_exited", self, "_on_lod1_exited")
	pass 

### Perhaps clean up this code to be clear lod level setters instead
func _on_lod0_entered(lod_node: Node) -> void:
	if lod_node is LodModel:
		Log.trace(self, "", "LodModel:%s entered lod0 range" %lod_node.name)
		lod_node.set_lod(0)
	
func _on_lod0_exited(lod_node: Node) -> void:
	if lod_node is LodModel:
		Log.trace(self, "", "LodModel:%s exited lod0 range" %lod_node.name)
		if lod1.overlaps_area(lod_node):
			lod_node.set_lod(1)
	
func _on_lod1_entered(lod_node: Node) -> void:
	if lod_node is LodModel:
		Log.trace(self, "", "LodModel:%s entered lod1 range" %lod_node.name)
		if !lod0.overlaps_area(lod_node):
			lod_node.set_lod(1)
	
func _on_lod1_exited(lod_node: Node) -> void:
	if lod_node is LodModel:
		Log.trace(self, "", "LodModel:%s exited lod1 range" %lod_node.name)
		lod_node.set_lod(2)

func _set_lod0_dist(val: float) -> void:
	if lod0 != null:
		lod0.get_node("CollisionShape").scale = Vector3.ONE * val

func _set_lod1_dist(val: float) -> void:
	if lod1 != null:
		lod1.get_node("CollisionShape").scale = Vector3.ONE * val
