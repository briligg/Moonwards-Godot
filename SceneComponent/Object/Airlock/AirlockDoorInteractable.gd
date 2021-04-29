extends Interactable
class_name AirlockDoorInteractable

export(NodePath) var animation_player_path
export(NodePath) var dock_point_path
#Emitted when entity interacts with me while open.
signal closed()
#Emitted when entity interacts with me while closed.
signal opened()
#Emitted when I am completely closed and will not let air out.
signal finished()

const FINISHED : String = "finished"

export(String) var animation_name
# If this door is dockable to a passenger pod
export(bool) var is_dock_door: bool = false

onready var anim = get_node(animation_player_path)
onready var dock_point = get_node_or_null(dock_point_path)

var is_open: bool = false

var is_docked_to: bool = false

#Called when an airlock has finished opening or shutting.
func _animation_finished(_anim_name) -> void :
	emit_signal("finished")

func _ready():
	title = "Airlock Dock"
	
	#Listen for when animations are finished
	anim.connect("animation_finished", self, "_animation_finished")

func interact_with(_interactor : Node) -> void :
		if is_open:
				request_close()
		else:
				request_open()

puppet func netsync_door(val):
	if val == is_open:
		return
	else:
		emit_signal("opened")

func sync_for_new_player(peer_id):
	#Major hack to prevent premature calling
	yield(get_tree().create_timer(10), "timeout")
	Log.trace(self, "sync_for_new_player", "Attempting sync %s for player %s" % [get_path(), str(peer_id)])
	rpc_id(peer_id, "netsync_door", is_open )

puppet func request_close():
	if is_open:
		emit_signal("closed")
		if is_network_master():
			rpc("request_close")
		

puppet func request_open():
	if !is_open:
		emit_signal("opened")
		if is_network_master():
			rpc("request_open")

func open():
	anim.play(animation_name, -1, 0.65, false)
	is_open = true

func close():
	anim.play(animation_name, -1, -0.65, true)
	is_open = false
