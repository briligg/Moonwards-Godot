"""

	Use this class for showing-up independent screens within the game.

"""

tool
extends Spatial

# Member variables
var prev_pos = null
var last_click_pos = null
onready var viewport = $Viewport
onready var slide_control = $Viewport/SlideControl2

export(Array, Texture) var texture_slides
export(Array, String) var text_slides
var slide_index: int = 0
var slide_size: int = 0

func _ready():
	get_node("Area").connect("input_event", self, "_on_area_input_event")
	$Viewport/SlideControl2.connect("next_pressed", self, "_on_next_pressed")
	$Viewport/SlideControl2.connect("prev_pressed", self, "_on_prev_pressed")
	
	if texture_slides.size() != text_slides.size():
		assert(false)
		Log.error(self, "_ready", "Texture array size is not the same as text array size.")
	else:
		slide_size = texture_slides.size()
	
func _on_next_pressed():
	if slide_size > slide_index + 1:
		slide_index += 1
		slide_control.texture = texture_slides[slide_index]
	else:
		slide_control.texture = texture_slides[0]
		slide_index = 0

func _on_prev_pressed():
	if slide_index > 0:
		slide_index -= 1
		slide_control.texture = texture_slides[slide_index]
	else:
		slide_control.texture = texture_slides[slide_size - 1]
		slide_index = slide_size - 1

# Mouse events for Area
func _on_area_input_event(_camera, event, click_pos, _click_normal, _shape_idx):
	# Use click pos (click in 3d space, convert to area space)
	var pos = get_node("Area").get_global_transform().affine_inverse()
	# the click pos is not zero, then use it to convert from 3D space to area space
	if (click_pos.x != 0 or click_pos.y != 0 or click_pos.z != 0):
		pos *= click_pos
		last_click_pos = click_pos
	else:
		# Otherwise, we have a motion event and need to use our last click pos
		# and move it according to the relative position of the event.
		# NOTE: this is not an exact 1-1 conversion, but it's pretty close
		pos *= last_click_pos
		if (event is InputEventMouseMotion or event is InputEventScreenDrag):
			pos.x += event.relative.x / viewport.size.x
			pos.y += event.relative.y / viewport.size.y
			last_click_pos = pos
  
	# Convert to 2D
	pos = Vector2(pos.x, pos.y)
  
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
	if (prev_pos == null):
		prev_pos = pos
	if (event is InputEventMouseMotion):
		event.relative = pos - prev_pos
	prev_pos = pos
	
	# Send the event to the viewport
	viewport.input(event)
