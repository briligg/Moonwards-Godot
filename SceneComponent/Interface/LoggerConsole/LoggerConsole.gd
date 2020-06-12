extends CanvasLayer

func _ready() -> void :
	$Panel.anchor_right = $Container.anchor_right
	$Panel.anchor_bottom = $Container.anchor_bottom

func _input(event: InputEvent) -> void:
	#Toggle whether I am visible or not.
	if event.is_action_pressed("toggle_logger"):
		var visible_status : bool = !get_child(0).visible
		for child in get_children() :
			child.visible = visible_status


func _filter_toggled(_button_pressed):
	var trace = get_node("Container/Filters/Trace").pressed
	var debug = get_node("Container/Filters/Debug").pressed
	var warning =  get_node("Container/Filters/Warning").pressed
	var error =  get_node("Container/Filters/Error").pressed
	var critical =  get_node("Container/Filters/Critical").pressed
	get_node("Container/LoggerText").filter_text(trace, debug, warning, error, critical)
