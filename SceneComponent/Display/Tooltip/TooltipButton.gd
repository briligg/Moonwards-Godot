extends Spatial

#Buttons for the TooltipData to use.
var tooltip_data : TooltipData = TooltipData.new()

#When hovered over, this is true. When not hovered, this is false.
#var mouse_hovered : bool = false

#Allows pressed animation.
var pressed : bool = false

onready var anim_player : AnimationPlayer = $Anim
onready var mesh : MeshInstance = $Area/Spatial

export var bbtext_fields : PoolStringArray = []

export var title : String


func _ready() -> void:
	#Make sure tooltip_data is deleted when I am being freed.
	connect("tree_exiting", tooltip_data, "free_myself")
	
	get_node("Area").connect("input_event", self, "on_input_event")
	
	#Set the TooltipData.
	tooltip_data.bbtext_fields = bbtext_fields
	tooltip_data.title = title

#Set mesh instance back to it's default values.
func _reset_mesh() -> void :
	mesh.scale = Vector3(1,1,1)

func on_input_event(_camera, event, _click_pos, _click_normal, _shape_idx):
	if event is InputEventMouseButton :
		if event.pressed :
			anim_player.play("pressed")
		
		#Only bring up TooltipDisplay if the player has pressed and released me.
		if event.pressed == false :
			anim_player.stop()
			_reset_mesh()
			pressed = false
			Log.warning(self, "" , "Tooltip question mark received a click")
			Signals.Hud.emit_signal(Signals.Hud.TOOLTIP_MENU_DISPLAYED, tooltip_data)
