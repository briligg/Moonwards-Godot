extends CanvasLayer

onready var container : ViewportContainer = $ViewportContainer
onready var panel : Panel = $ViewportContainer/Viewport/Panel

var displayed_node : Node
var original_parent : Node #Allows us to put the node back in place when done.

func _close_pressed() -> void :
	$Close.hide()
	panel.hide()
	Helpers.reparent(displayed_node, original_parent)
	displayed_node = null
	original_parent = null

func _ready() -> void :
	$Close.connect("pressed", self, "_close_pressed")
	Signals.Hud.connect(Signals.Hud.START_ELEMENT_WINDOW, self, "_start_element_window")

func _start_element_window(new_node : Node) -> void :
	$Close.show()
	container.show()
	original_parent = new_node.get_parent()
	Helpers.reparent(new_node, panel)
	panel.show()
	displayed_node = new_node
	Helpers.capture_mouse(false)
