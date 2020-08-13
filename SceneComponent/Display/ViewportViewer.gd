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
var viewport: Node = null
var content_instance = null
export(PackedScene) var content = null
export(bool) var hologram = false

# Mouse events for Area
func _on_area_input_event(_camera, event, click_pos, _click_normal, _shape_idx):
	# Use click pos (click in 3d space, convert to area space)
	var pos = get_node("Area").get_global_transform().affine_inverse()
	# the click pos is not zero, then use it to convert from 3D space to area space
	if (click_pos.x != 0 or click_pos.y != 0 or click_pos.z != 0):
		pos *= click_pos

	# Convert to 2D
	pos = Vector2(pos.x * screen.scale.x, pos.y * screen.scale.y)

	# Convert to viewport coordinate system
	# Convert pos to a range from (0 - 1)
	pos.y *= -1
	pos += Vector2(1, 1)
	pos = pos / 2

	# Convert pos to be in range of the viewport
	pos.x *= viewport.size.x 
	pos.y *= viewport.size.y

	# Set the position in event
	event.position = pos
	event.global_position = pos

	# Send the event to the viewport
	viewport.input(event)


func _ready():
	set_process_input(false)
	viewport = get_node("Viewport")
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
