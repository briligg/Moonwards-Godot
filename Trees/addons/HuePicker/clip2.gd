#Clipper for ClassicControls to fix buggy input handle
tool
extends Control

signal color_changed(color)

export(Color) var color : Color setget color_changed

onready var picker = $Hider/Viewport/ColorPicker
onready var Hider = $Hider
onready var viewport : Viewport = $Hider/Viewport

var isReady : bool = false

func _ready() -> void:
	if color == null:	color = ColorN('white')
	isReady = true

	Hider.rect_size = rect_size
	viewport.size = rect_size

	connect("resized", self, "_on_ClassicControls_resized")

	set_meta("_editor_icon", preload("res://Trees/addons/HuePicker/icon_classic_controls.svg"))


func color_changed(value : Color) -> void:
	color = value
	
	#TODO: This line is so we know to update the built-in picker if a property
	#is set from within the Godot editor. Will cause problems for downstream
	#Plugins, so try to figure out a way to determine that we're SPECIFICALLY
	#editing this property from the Inspector, somehow.  Hack!!!
	if picker != null: 
		picker.color = value
		picker.update_shaders()
	emit_signal('color_changed', value)



#Handles capture
func _gui_input(event : InputEvent) -> void:
	
	#Stop ignoring input if the mouse position is within the acceptable capture zone.
	if get_local_mouse_position().y >=0:
		viewport.gui_disable_input = false




func _on_ClassicControls_resized() -> void:
	viewport.get_node("PanelContainer/TransBG").region_rect.size.x = max(260,rect_size.x)



func update_shaders() -> void:
	if picker != null: 
		picker.update_shaders()
	