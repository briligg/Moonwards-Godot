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
onready var screen: Node = self
onready var collision_box: CollisionShape = get_node("Area/CollisionShape")
onready var viewport: Node = get_node("Viewport")

var content_instance = null
export(PackedScene) var content = null
export(bool) var hologram = false


func _ready():
	set_process_input(false)
	if content != null:
		content_instance = content.instance()
		viewport.add_child(content_instance)
	else:
		Log.trace(self, "_ready", "Screen View without a content")
	
	get_node("Area").connect("input_event", self, "_on_area_input_event")
	
	
	if hologram:
		var mat = $Area/Quad.get_surface_material(0)
		mat.albedo_color.a = 0.7
		mat.flags_transparent = true
		$Area/Quad.set_surface_material(0, mat)

# Mouse events for Area
func _on_area_input_event(_camera, event, click_pos, _click_normal, _shape_idx):
	
	if !(event is InputEventMouseButton):
		return
		
	var screen_pos = screen.global_transform.origin
	var screen_size = collision_box.scale
	
	var real_click_pos = Vector2(abs(screen_pos.x) - abs(click_pos.x), 
			abs(screen_pos.y) - abs(click_pos.y) )

	var percentage_pos = Vector2(real_click_pos.x / screen_size.x, real_click_pos.y / screen_size.y)

	#Convert to viewport coordinate system
	#Convert pos to a range from (0 - 1)
	percentage_pos.y *= -1
	percentage_pos += Vector2(1, 1)
	percentage_pos = percentage_pos / 2
	
	#Account for screen scale
	percentage_pos.x *= screen.scale.x
	percentage_pos.y *= screen.scale.y
	
	var viewport_click_pos = Vector2(percentage_pos.x * viewport.size.x, percentage_pos.y * viewport.size.y)
	#Set the position in event
	event.position = viewport_click_pos
	event.global_position = viewport_click_pos

	#Send the event to the viewport
	viewport.input(event)
