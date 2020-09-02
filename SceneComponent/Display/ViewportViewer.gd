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

#Emitted when the content has been added to viewport.
signal content_prepared(content_node)

# Member variables
onready var screen: Node = self
onready var collision_box: CollisionShape = get_node("Area/CollisionShape")
onready var viewport: Node = get_node("Viewport")

var content_instance = null
export(PackedScene) var content = null
export(NodePath) var content_as_child = null
export(bool) var hologram = false


func _ready():
	set_process_input(false)
	if content != null:
		#Do not allow both Content and content as child to
		#be set together.
		assert(content_as_child == null)
		content_instance = content.instance()
		viewport.add_child(content_instance)
		call_deferred("emit_signal", "content_prepared", content_instance)
	
	elif content_as_child != null :
		#The NodePath given must be a child of myself.
		content_instance = get_node(content_as_child)
		remove_child(content_instance)
		viewport.add_child(content_instance)
		call_deferred("emit_signal", "content_prepared", content_instance)
	else:
		Log.trace(self, "_ready", "Screen View without a content")
	
	get_node("Area").connect("input_event", self, "_on_area_input_event")
	
	
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

	var percentage_pos = Vector2(real_click_pos.x / screen_size.x, real_click_pos.y / screen_size.y)

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
