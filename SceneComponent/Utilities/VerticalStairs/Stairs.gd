tool
extends "res://SceneComponent/Utilities/Interactable/Interactable.gd"

var climb_points = []
var step_size = 0.0535

export (float) var height = 1 setget _set_height


func _ready():
	#Listen to when I am interacted with.
	connect("interacted_with", self, "interacted_with")
	
	var step_position = $CollisionShape.global_transform.origin
	var max_y = step_position.y + $CollisionShape.shape.extents.y
	step_position.y -= $CollisionShape.shape.extents.y
	
	#Calculate how large each step needs to be.
	while true:
		climb_points.append(step_position)
		step_position.y += step_size
		if step_position.y > max_y:
			break

#Let the interactor know they interacted with me.
func interacted_with(_interactor : Node) -> void :
	if _interactor.has_method("climb_stairs") :
		#Make the interactor climb stairs.
		_interactor.climb_stairs(global_transform.origin.y + height)

#Set the height of the stairs
func _set_height(var new_height) :
	height = new_height

#Determine which side the player should be facing when climbing.
func _get_look_direction(var position):
	var flat_position = global_transform.origin
	flat_position.y = position.y
	
	if rad2deg(global_transform.basis.z.angle_to((flat_position - position).normalized())) < 90.0:
		return global_transform.basis.z
	else:
		return -global_transform.basis.z

func _create_debug_line(var from, var to):
	var im = ImmediateGeometry.new()
	add_child(im)
	im.global_transform.origin = Vector3()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	im.add_vertex(from + Vector3(0, 0.1, 0.0))
	im.add_vertex(to + Vector3(0, 0.1, 0.0))
	im.end()

func _create_debug_object(var location):
	var mesh_instance = MeshInstance.new()
	var mesh = CubeMesh.new()
	var material = SpatialMaterial.new()
	
	mesh.size = Vector3(0.01, 0.01, 0.01)
	material.albedo_color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1), 1)
	material.flags_unshaded = true
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	
	add_child(mesh_instance)
	mesh_instance.global_transform.origin = location
