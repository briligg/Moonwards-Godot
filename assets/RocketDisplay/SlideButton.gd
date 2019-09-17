extends Control

export (NodePath)var control_path
export (NodePath)var info_box
var active = false
export (int) var stage

func _ready():
	get_node(control_path).RegisterSlideButton(self)

func SetActive(var _active):
	active = _active
	if active:
		$TextureRect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		$TextureRect.modulate = Color(1.0, 1.0, 1.0, 0.25)

func Clicked(event):
	if event.is_action("left_click"):
		get_node(control_path).GoToSlide($Label.text)
