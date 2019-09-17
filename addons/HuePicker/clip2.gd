#Clipper for ClassicControls to fix buggy input handle
tool
extends Control


export(Color) var color setget color_changed
signal color_changed(color)

var isReady = false

func _ready():
	if color == null:	color = ColorN('white')
	isReady = true

	$Hider.rect_size = rect_size
	$Hider/Viewport.size = rect_size

	connect("resized", self, "_on_ClassicControls_resized")

	set_meta("_editor_icon", preload("res://addons/HuePicker/icon_classic_controls.svg"))


func color_changed(value):
	color = value
	
	#TODO: This line is so we know to update the built-in picker if a property
	#is set from within the Godot editor. Will cause problems for downstream
	#Plugins, so try to figure out a way to determine that we're SPECIFICALLY
	#editing this property from the Inspector, somehow.  Hack!!!
	if $Hider/Viewport/ColorPicker != null: 
		$Hider/Viewport/ColorPicker.color = value
		$Hider/Viewport/ColorPicker.update_shaders()
	emit_signal('color_changed', value)



#Handles capture
func _gui_input(event):
	
	#Stop ignoring input if the mouse position is within the acceptable capture zone.
	if get_local_mouse_position().y >=0:
		$Hider/Viewport.gui_disable_input = false




func _on_ClassicControls_resized():
	$Hider/Viewport/PanelContainer/TransBG.region_rect.size.x = max(260,rect_size.x)



func update_shaders():
	if $Hider/Viewport/ColorPicker != null: 
		$Hider/Viewport/ColorPicker.update_shaders()
	