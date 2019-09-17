extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",self,"_on_body_entered")
	connect("body_exited",self,"_on_body_exited")

func _on_body_entered(body):
	if body is KinematicBody:
		get_node("../../../UpperGallery").visible = false 
		get_node("../../../FirstGallery").visible = false 
	pass
	
func _on_body_exited(body):
	if body is KinematicBody:
		get_node("../../../UpperGallery").visible = true 
		get_node("../../../FirstGallery").visible = true 
	pass
