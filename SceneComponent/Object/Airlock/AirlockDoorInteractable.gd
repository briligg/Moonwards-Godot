extends Interactable
class_name AirlockDoorInteractable

export(NodePath) var animation_player
export(String) var animation_name
# If this door is dockable to a passenger pod
export(bool) var is_dock_door: bool = false

onready var anim = get_node(animation_player)
var is_open: bool = false


func _ready():
	title = "Airlock Dock"
	

func interact_with(_interactor : Node) -> void :
	if is_open:
		close()
	else:
		open()

func open():
	anim.play(animation_name, -1, 0.65, false)
	is_open = !is_open

func close():
	anim.play(animation_name, -1, -0.65, true)
	is_open = !is_open
