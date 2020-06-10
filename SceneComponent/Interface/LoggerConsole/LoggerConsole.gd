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
