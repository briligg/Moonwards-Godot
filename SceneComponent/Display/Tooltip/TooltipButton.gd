extends Spatial

#Buttons for the TooltipData to use.
var tooltip_data : TooltipData = TooltipData.new()


#Allows pressed animation.
var pressed : bool = false

onready var anim_player : AnimationPlayer = $Anim
onready var mesh : MeshInstance = $Model/Spatial

export var bbtext_fields : PoolStringArray = []

export var title : String

func _hovered(hovered_over : bool) -> void :
	if hovered_over :
		anim_player.play("hovered")
	else : 
		anim_player.play("unhovered")

func _ready() -> void:
	#This allows me to have hover functionality.
	connect("mouse_entered", self, "_hovered", [true])
	connect("mouse_exited", self, "_hovered", [false])
	
	#Make sure tooltip_data is deleted when I am being freed.
	connect("tree_exiting", tooltip_data, "free_myself")
	
	connect("input_event", self, "on_input_event")
	
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
