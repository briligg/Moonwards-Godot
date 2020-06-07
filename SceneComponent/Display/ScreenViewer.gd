tool
extends Spatial

# Member variables
var prev_pos = null
var last_click_pos = null
var viewport = null
export(PackedScene) var Content = null
export(Vector2) var Size = Vector2(1024,700)
export(bool) var Hologram = false

# Mouse events for Area
func _on_area_input_event(camera, event, click_pos, click_normal, shape_idx):
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

func _ready():
	set_process_input(false)
	viewport = get_node("Viewport")
	viewport.size = Size
	if Content != null:
		viewport.add_child(Content.instance())
	else:
		print("ERROR: Assign a Content to this screen!")
	
	get_node("Area").connect("input_event", self, "_on_area_input_event")
	get_node("InteractionTrigger").connect("body_entered", self, "_start_interaction")
	get_node("InteractionTrigger").connect("body_exited", self, "_stop_interaction")
	
	if Hologram:
		var mat = $Area/Quad.get_surface_material(0)
		mat.albedo_color.a = 0.7
		mat.flags_transparent = true
		$Area/Quad.set_surface_material(0, mat)

func _start_interaction(body):
	set_process_input(true)
	var player = body.get_parent()
	if(player.has_method("ShowMouseCursor")):
		player.call("ShowMouseCursor")

func _stop_interaction(body):
	set_process_input(false)
	var player = body.get_parent()
	if(player.has_method("HideMouseCursor")):
		player.call("HideMouseCursor")
