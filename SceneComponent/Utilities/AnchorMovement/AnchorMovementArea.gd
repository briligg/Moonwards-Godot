extends Area

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body is AEntity:
		body.movement_anchor.anchor_node = self
		body.movement_anchor.is_anchored = true
		
#func _on_body_exited(body):
#	if body is AEntity:
#		body.movement_anchor.anchor_node = null
#		body.movement_anchor.is_anchored = false
