tool
extends Control
export(PackedScene) var Content = preload("res://assets/Slides/Lunar Machines/Regolith.tscn")


func _ready():
	get_viewport().connect("size_changed",self,"_on_size_changed")
	$ColorRect/ViewportContainer/Viewport.add_child(Content.instance())
	
func _on_size_changed():
	var Newsize = get_viewport().get_visible_rect().size
	$ColorRect.rect_scale = Newsize/Vector2(1366,768)
