extends Spatial

var attached_to 

func _ready() -> void:
	$Interactable.connect("interacted_by", self, "interacted_by")
	$Interactable.connect("sync_for_new_player", self, "sync_for_new_player")
	
func interacted_by(body):
	if body is VehicleEntity :
		return
	
	if body.movement_anchor_data.anchor_node == self:
		detach_anchor(body)
	else:
		attach_anchor(body)

func attach_anchor(body):
	if body is AEntity:
		body.movement_anchor_data.attach(self)
		if body.has_node("AnchorMovement") :
			body.get_component("AnchorMovement").set_status_visibility(true)
		attached_to = body
 
func detach_anchor(body):
	if body is AEntity:
		body.movement_anchor_data.detach()
		if body.has_node("AnchorMovement") :
			body.get_component("AnchorMovement").set_status_visibility(false)
		attached_to = null

func sync_for_new_player(peer_id):
	if attached_to:
		var node_path = attached_to.get_path()
		rpc_id(peer_id, "attach_on_join", node_path)

puppet func attach_on_join(node_path):
	var body = get_node_or_null(node_path)
	while body == null:
		yield(get_tree(), "physics_frame")
		body = get_node_or_null(node_path)
	if body is AEntity:
		body.movement_anchor_data.attach(self)
 
