extends Interactable

export(NodePath) var animation_player
export(String) var animation_name

onready var anim = get_node(animation_player)
var is_open: bool = true

func _ready():
	title = "Airlock Dock"
	

func interact_with(interactor : Node) -> void :
	if is_open:
		anim.play(animation_name, -1, 0.65, false)
		is_open = !is_open
	else:
		anim.play(animation_name, -1, -0.65, true)
		is_open = !is_open
