"""

	Main Node used as a container to hold the slides.
	Best to set it's size to Windows' width and height (see project's properties)
	currently: 1920x1080

"""
tool
extends Control
class_name Presentation, "res://Assets/Icons/Presentation.svg"

var idx: int = 0
onready var slide_count: int = get_child_count()


func _ready():
	_hide_all_slides()
	
	var first_slide: Node = get_child(0)
	if first_slide.is_class("Slide"):
		first_slide.show()
	else:
		Log.warning(self, "_ready",
				"Item selected for a load isn't of Slide class type'")


func get_class(): return "Presentation"


func _hide_all_slides() -> void:
	for i in get_children():
		if i.has_method("hide"):
			i.hide()


func _on_next_clicked() -> void:
	var current_slide = get_child(idx)
	if current_slide.has_method("hide"):
		current_slide.hide()
	
	if idx < slide_count:
		idx += 1
		var next_slide: Node = get_child(idx)
		if(next_slide.is_class("Slide")):
			next_slide.show()
		else:
			Log.warning(self, "_on_next_clicked",
					"Item selected for a load isn't of Slide class type'")


func _on_prev_clicked() -> void:
	var current_slide = get_child(idx)
	if current_slide.has_method("hide"):
		current_slide.hide()
	
	if idx > 0:
		idx -= 1
		var prev_slide: Node = get_child(idx)
		if(prev_slide.is_class("Slide")):
			prev_slide.show()
		else:
			Log.warning(self, "_on_next_clicked",
					"Item selected for a load isn't of Slide class type'")


# legacy code, if problems with slides resize reconnect with
# get_viewport().connect("size_changed", self, "_on_size_changed")
# on the _ready() function
#
#func _on_size_changed() -> void:
#	var new_size = get_viewport().get_visible_rect().size
#	self.rect_scale = new_size/rect_size
