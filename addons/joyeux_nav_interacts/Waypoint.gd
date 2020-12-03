extends Position3D
class_name Waypoint

var offset1 : Vector3 = Vector3.ZERO
var offset2 : Vector3 = Vector3.ZERO

#Waypoints must be used on entrances to rooms with navigation meshes
#Later on, draw a custom gizmo for it

func _ready():
	offset1 = $Offset1.translation
	offset2 = $Offset2.translation
