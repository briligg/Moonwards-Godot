"""
	Use this class for showing-up independent screens within the game.
	
	A modified version of a standard Godot's Viewport that will handle the input
	and distribute the events accordingly into viewport's UI controls.
	
	Assign the Context variable on the Inspector. Content is a scene that will be
	displayed within the screen (viewport) - usually contains UI Controls that player
	can click on the display.
"""

tool
extends Spatial

# Member variables
export(PackedScene) var content = null
export(Vector2) var mesh_size = Vector2(1920,1080)
export(Vector2) var viewport_size = Vector2(1920,1080)
export(bool) var track_camera = false
export(bool) var hologram = false

onready var screen: Node = self
onready var collision_box: CollisionShape = get_node("Area/CollisionShape")
onready var viewport: Node = get_node("Viewport")

var screen_parent: Node = null

var content_instance = null

#When track_camera is on, rotate myself to face the camera at all times.
func _process(_delta : float) -> void :
	var camera : Camera = get_tree().root.get_camera()
	if camera != null:
		rotation_degrees = camera.rotation_degrees

func _ready():
	set_process_input(false)
	content_instance = content.instance()
	viewport.add_child(content_instance)
	
	get_node("Area").connect("input_event", self, "_on_area_input_event")
	
	#Adjust the scale of the collision shape to what the developer specified.
	$Area/CollisionShape.scale = Vector3(mesh_size.x / 1745, mesh_size.y / 1728 ,1)
	#Adjust the viewport screen size based on what the dev specified.
	$Viewport.size = viewport_size
	
	#Track the camera if the bool is true.
	if not track_camera :
		set_process(false)
	
	if hologram:
		var mat = $Area/CollisionShape/Quad.get_surface_material(0)
		mat.albedo_color.a = 0.7
		mat.flags_transparent = true
		$Area/CollisionShape/Quad.set_surface_material(0, mat)

# Mouse events for Area
func _on_area_input_event(_camera, event, click_pos, _click_normal, _shape_idx):
	if !(event is InputEventMouseButton):
		return
		
	#Get the size of the viewport and it's world position.
	var screen_pos = screen.global_transform.origin
	var screen_size = collision_box.scale
	
	#Convert the click position from world to local, using the viewport's world position
	var real_click_pos = click_pos - screen_pos 

	#Compensate for rotation for the x axis
	var x_compens = cos(deg2rad(screen_parent.rotation_degrees.y))
	var z_compens = sin(deg2rad(screen_parent.rotation_degrees.y))
	var x_axis = x_compens * real_click_pos.x / screen_size.x
	var z_axis = -z_compens * real_click_pos.z / screen_size.x
	
	var percentage_pos = Vector2(x_axis + z_axis, real_click_pos.y / screen_size.y )
	
	#unused variables
#	var zclick_pos = real_click_pos.z / screen_size.x
	
	#Convert pos to a range from (0 - 1)
	percentage_pos.y *= -1
	percentage_pos += Vector2(1, 1)
	percentage_pos = percentage_pos / 2
	
	#Account for screen scale
	percentage_pos.x *= screen.scale.x
	percentage_pos.y *= screen.scale.y
	
	#Convert to viewport coordinates
	var viewport_click_pos = Vector2(percentage_pos.x * viewport.size.x, percentage_pos.y * viewport.size.y)
	
	#Set the position in the event
	event.position = viewport_click_pos
	event.global_position = viewport_click_pos

	#Send the event to the viewport
	viewport.input(event)
