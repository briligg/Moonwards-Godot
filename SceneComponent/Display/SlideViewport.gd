tool
extends Viewport
class_name SlideViewport, "res://Assets/Icons/SlideViewport.svg"

export(PackedScene) var Content = null


func _ready() -> void:
	if Content != null:
		add_child(Content.instance())


func get_class() -> String: return "SlideViewport"
