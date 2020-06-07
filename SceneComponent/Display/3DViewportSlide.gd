tool
extends Control
export(PackedScene) var Content = preload("res://Assets/Slides/BucknellRocket/Slide00_VP.tscn")
var content_path = ""
var index = 0
var disabled_direction = 1 #1 is for right click/ left key, 2 is for left click, right key 0 is for none
var delay

func update_slides():
	if index != 0 and index < $ColorRect/Content.get_child_count():
		$ColorRect/Content.get_child(index-1).visible = false
		remove_previous_viewport_content()
		if not disabled_direction == 0:
			disabled_direction = 0
	elif index == 0:
		disabled_direction = 1
	if index < $ColorRect/Content.get_child_count()-1:
		$ColorRect/Content.get_child(index+1).visible = false
		remove_previous_viewport_content()
	else:
		disabled_direction = 2
	if index < $ColorRect/Content.get_child_count():
		$ColorRect/Content.get_child(index).visible = true
		add_new_viewport_content()
	hide_buttons_on_edges()

func _ready():
	create_content_path()
	update_slides()
	get_viewport().connect("size_changed",self,"_on_size_changed")
	if($ColorRect/ViewportContainer/Viewport.get_child_count() == 0):
		$ColorRect/ViewportContainer/Viewport.add_child(Content.instance())
	delay = Timer.new() 
	delay.wait_time = 0.5
	delay.one_shot = true
	delay.autostart = false
	$ColorRect.add_child(delay)
	
func _on_size_changed():
	var Newsize = get_viewport().get_visible_rect().size
	$ColorRect.rect_scale = Newsize/Vector2(1024,700)

func create_content_path():
	var ss = Content.resource_path.split("/")
	content_path = Content.resource_path.substr(0, Content.resource_path.length() - ss[ss.size()-1].length())

func construct_viewport_res_path(index):
	var s = ""
	if(index < 10):
		s += "0" + str(index)
	else:
		s += str(index)
	
	return content_path + "Slide" + s + "_VP.tscn"

func add_new_viewport_content():
	var vp_scene = load(construct_viewport_res_path(index)).instance()
	$ColorRect/ViewportContainer/Viewport.add_child(vp_scene)

func remove_previous_viewport_content():
	if($ColorRect/ViewportContainer/Viewport.get_child_count() > 0):
		var vp_content = $ColorRect/ViewportContainer/Viewport.get_child(0)
		$ColorRect/ViewportContainer/Viewport.remove_child(vp_content)
		vp_content.queue_free()

func hide_buttons_on_edges():
	if(not $ColorRect/Buttons/NextButton.visible):
		$ColorRect/Buttons/NextButton.show()
	if(not $ColorRect/Buttons/PrevButton.visible):
		$ColorRect/Buttons/PrevButton.show()
	
	if(disabled_direction == 1):
		$ColorRect/Buttons/PrevButton.hide()
	elif(disabled_direction == 2):
		$ColorRect/Buttons/NextButton.hide()

func next_button_clicked():
	index += 1
	update_slides()

func prev_button_clicked():
	index -= 1
	update_slides()
