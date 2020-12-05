extends Area
class_name Interactable
"""
 For interacting with the player. 
 Use inside the body that you would like it
 to connect to. 
 I emit interacted_with when an interactor interacts with me. 
	Passes the node that requested the interact in the signal.
"""

signal interacted_by(interactor_ray_cast)
signal sync_for_new_player(peer_id)

signal title_changed(new_title_string)
signal display_info_changed(new_description_string)

# Flags that are only processed if is_networked evaluates to true.
# CLIENT_SERVER: Runs on both the requesting client & the server. This is the default state.
#    Actions that require both validation, and need to run on both sides as both the state & player prespective get changed, for example.
# SERVER_ONLY: Only runs on the server, these are actions that will likely be propagated inherently by existing features. 
#    Things such as climbing stairs, modifying positions, etc.
# CLIENT_ONLY: Only happens locally on the client, but still requests permission from the server. 
#    Actions that may need validation, or that need to be tracked.
# PROPAGATED: Runs on both the server, the requesting client, and all other clients.
enum NetworkMode {
	CLIENT_SERVER,
	CLIENT_ONLY,
	SERVER_ONLY,
	PROPAGATED,
}
#If you do not want to have any networking on the Interactable, then set is_networked to false.

export(float) var max_interact_distance = 5.0
#This is what is displayed when an interactor can interact with me.
export var display_info : String = "Interactable" setget set_display_info
#This string is displayed in the text of the InteractsMenu button.
export var title : String = "Title" setget set_title
#Interactions will be requested from the server before bouncing back to the requesting client(s).
export var is_networked: bool = true
### Supplementary networking flags, these are only checked for if `is_networked` is true.
export(NetworkMode) var network_mode = NetworkMode.CLIENT_SERVER
# Whether we should sync the state of this interactable for a newly joined player
export(bool) var is_sync_for_new_player = true
# Whether or not this interactable is available  to receive interactions.
var is_available: bool = true
#Whether or not this interactable has active collision detection.
export var interactions_active : bool = true setget set_active

var owning_entity: AEntity = null

func _ready() -> void :
	collision_layer = 32768
	collision_mask = 0
	Signals.Network.connect(NetworkSignals.NEW_PLAYER_POST_LOAD, self, "sync_for_new_player")

func get_info() -> String :
	#Show what the display info should be for interacting with me.
	return display_info

func get_title() -> String :
	return title

func interact_with(interactor : Node) -> void :
	#Someone requested interaction with me.
	emit_signal("interacted_by", interactor)

# warning-ignore:function_conflicts_variable
func is_networked() -> bool :
	return is_networked

#Turns on or shuts off this interactables collision detection.
func set_active(become_active : bool) -> void :
	if become_active :
		set_collision_layer_bit(15, true)
	else :
		set_collision_layer_bit(15, false)
	
	interactions_active = become_active

func set_display_info(new_display_info : String) -> void :
	display_info = new_display_info
	emit_signal("display_info_changed", display_info)

func set_title(new_title : String) -> void :
	title = new_title
	emit_signal("title_changed", title)

func sync_for_new_player(peer_id):
	emit_signal("sync_for_new_player", peer_id)
