extends Spatial


func _ready() -> void:
	$Interactable.connect("interacted_by", self, "interacted_by")

func interacted_by(body):
	if body.movement_anchor_data.anchor_node == self:
		detach_anchor(body)
	else:
		attach_anchor(body)

func attach_anchor(body):
	if body is AEntity:
		body.movement_anchor_data.anchor_node = self
		body.movement_anchor_data.is_anchored = true
 
func detach_anchor(body):
	if body is AEntity:
		body.movement_anchor_data.anchor_node = null
		body.movement_anchor_data.is_anchored = false
