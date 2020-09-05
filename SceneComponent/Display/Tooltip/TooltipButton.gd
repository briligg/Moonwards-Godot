extends Spatial

#Buttons for the TooltipData to use.
var tooltip_data : TooltipData = TooltipData.new()


export var bbtext_fields : PoolStringArray = []

export var title : String


func _ready() -> void:
	#Make sure tooltip_data is deleted when I am being freed.
	connect("tree_exiting", tooltip_data, "free_myself")
	
	get_node("Area").connect("input_event", self, "on_input_event")
	
	#Set the TooltipData.
	tooltip_data.bbtext_fields = bbtext_fields
	tooltip_data.title = title

func on_input_event(_camera, event, _click_pos, _click_normal, _shape_idx):
	if event is InputEventMouseButton && event.pressed :
		Log.warning(self, "" , "Tooltip question mark received a click")
		Signals.Hud.emit_signal(Signals.Hud.TOOLTIP_MENU_DISPLAYED, tooltip_data)
