extends Interactable
class_name AirlockDoorInteractable

export(NodePath) var animation_player_path
export(NodePath) var dock_point_path
export(String) var animation_name
# If this door is dockable to a passenger pod
export(bool) var is_dock_door: bool = false

onready var anim = get_node(animation_player_path)
onready var dock_point = get_node_or_null(dock_point_path)

var is_open: bool = false

func interact_with(_interactor : Node) -> void :
	update_door()

func open():
	anim.play(animation_name, -1, 0.65, false)

func close():
	anim.play(animation_name, -1, -0.65, true)

func update_door():
	if !is_open:
		open()
	else:
		close()
	is_open = !is_open

puppet func netsync_door(val):
	if val == is_open:
		return
	else:
		update_door()

func sync_for_new_player(peer_id):
	rpc_id(peer_id, "netsync_door", is_open )
	
