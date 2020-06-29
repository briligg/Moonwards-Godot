extends Spatial

func _ready():
	# Make the gizmo disabled by default.
	update(false);

func update(var is_active):
	# Based on is_active, change the visibility of the select gizmo.
	visible = is_active;

func axis_set(new_axis):
	# Because the select gizmo has no axes, we can just ignore this function!
	pass