tool
extends Spatial

var body_counter: int = 0

func _ready():
	$PlayArea.connect("body_entered", self, "_on_body_entered")
	$PlayArea.connect("body_exited", self, "_on_body_exited")


func _on_body_entered(_body: Node) -> void:
	if body_counter == 0:
		var content = $Screen.content_instance
		if content != null:
			if content.has_method("play"):
				content.play()
	
	body_counter += 1


func _on_body_exited(_body: Node) -> void:
	body_counter -= 1
	
	if body_counter == 0:
		var content = $Screen.content_instance
		if content != null:
			if content.has_method("stop"):
				content.stop()
