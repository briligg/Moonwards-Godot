tool
extends Control
export(PackedScene) var Content = preload("res://assets/Slides/Lunar Machines/Regolith.tscn")
var index = 0 
var disabled_direction = 1 #1 is for right click/ left key, 2 is for left click, right key 0 is for none
var delay

func update_slides():
	if index != 0 and index < $ColorRect/Content.get_child_count():
		$ColorRect/Content.get_child(index-1).visible = false
		if not disabled_direction == 0:
			disabled_direction = 0
	elif index == 0:
		disabled_direction = 1
	if index < $ColorRect/Content.get_child_count()-1:
		$ColorRect/Content.get_child(index+1).visible = false
		
	else:
		disabled_direction = 2
	if index < $ColorRect/Content.get_child_count():
		$ColorRect/Content.get_child(index).visible = true

func _ready():
	update_slides()
	get_viewport().connect("size_changed",self,"_on_size_changed")
	$ColorRect/ViewportContainer/Viewport.add_child(Content.instance())
	delay = Timer.new() 
	delay.wait_time = 0.5
	delay.one_shot = true
	delay.autostart = false
	$ColorRect.add_child(delay)
	
func _on_size_changed():
	var Newsize = get_viewport().get_visible_rect().size
	$ColorRect.rect_scale = Newsize/Vector2(1366,768)


func _input(event):
	if event is InputEventMouseButton and delay.is_stopped():
		
		if event.button_index == 1  and  disabled_direction != 2:
			index += 1
		if event.button_index == 2 and disabled_direction != 1:
			index -= 1
		update_slides()
		
	if event is InputEventKey and delay.is_stopped():
		if Input.is_action_pressed("ui_right") and  disabled_direction != 2:
			index += 1
		if Input.is_action_pressed("ui_left") and disabled_direction != 1:
			index -= 1
		update_slides()
