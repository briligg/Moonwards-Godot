tool
extends Interactable
class_name VerticalStairs

var climb_points = []
var step_size = 0.535

export(Mesh) var stair_step
export(Mesh) var stair_top
export(Mesh) var stair_bottom
export(float) var stair_step_length
export(float) var stair_bottom_length
export(float) var stair_width
export(int) var stairs_step_count

export(bool) var generate_editor_visual = false setget test_in_editor

var _total_length: float = 0.0

func _ready():
	#Listen to when I am interacted with.
	connect("interacted_by", self, "interacted_with")
	generate_stairs()
	if is_inside_tree():
		update_collision()

#Let the interactor know they interacted with me.
func interacted_with(_interactor : Node) -> void :
	if _interactor is ActorEntity:
		#Make the interactor climb stairs.
		_interactor.get_component("AMovementController").start_climb_stairs(self)

#Determine which side the player should be facing when climbing.
func get_look_direction(var position):
	var flat_position = global_transform.origin
	flat_position.y = position.y
	
#	var deg = rad2deg(global_transform.basis.z.angle_to((flat_position - position).normalized()))
	
	if rad2deg(global_transform.basis.z.angle_to((flat_position - position).normalized())) < 90.0:
		return global_transform.basis.z
	else:
		return -global_transform.basis.z

func generate_stairs():
	_total_length = (stairs_step_count * stair_step_length) + stair_bottom_length
	
	var top = MeshInstance.new()
	top.mesh = stair_top
	self.add_child(top)
	top.transform.origin = Vector3(0, stair_step_length, 0)
	for i in range(0, stairs_step_count):
		var step = MeshInstance.new()
		step.mesh = stair_step
		self.add_child(step)
		step.transform.origin.y = -1 * i * stair_step_length
	var bottom = MeshInstance.new()
	bottom.mesh = stair_bottom
	self.add_child(bottom)
	bottom.transform.origin.y = -1 * stairs_step_count * stair_step_length
	
func update_collision():
	$CollisionShape.scale.x = stair_width
	$CollisionShape.scale.z = stair_width
	$CollisionShape.scale.y = _total_length / 2
	$CollisionShape.transform.origin.y = -_total_length / 2
	
	var step_position = $CollisionShape.global_transform.origin
	var max_y = step_position.y + $CollisionShape.scale.y
	step_position.y -= $CollisionShape.scale.y
	
	#Calculate how large each step needs to be.
	while true:
		climb_points.append(step_position)
		step_position.y += step_size
		if step_position.y > max_y:
			break

func test_in_editor(_val):
	if _val:
		for n in self.get_children():
			if n != $CollisionShape:
				self.remove_child(n)
				n.queue_free()
		generate_stairs()
		update_collision()
		generate_editor_visual = _val
	else:
		generate_editor_visual = _val

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
