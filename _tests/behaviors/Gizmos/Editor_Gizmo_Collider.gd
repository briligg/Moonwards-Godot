extends StaticBody

export (String, "ALL", "X", "Y", "Z") var gizmo_axis = "ALL";

var collision_shape = null;

func _ready():
	collision_shape = get_node("CollisionShape");
func activate():
	collision_shape.disabled = false;
func deactivate():
	collision_shape.disabled = true;
