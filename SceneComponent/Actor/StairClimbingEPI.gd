extends EPIBase
class_name StairClimbingEPI

#Do not start climbing stairs unless we are actually a part
#of an entity.
export(bool) var can_climb_stairs : bool = true

var stairs = null
var climb_point = -1
var climb_points : Array = []
var climb_look_direction = Vector3.FORWARD
