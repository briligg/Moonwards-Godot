tool
extends ColorPicker

signal _needed_manual_click(ev) #Tell parent the event was consumed, needs to pass a click

var Focused : bool  setget _set_focused

func _ready() -> void:
	reposition()
	
func _draw() -> void:
	reposition()

func _gui_input(event : InputEvent) -> void:
#If mouse lies outside our input capture zone, tell the viewport to disable our input.

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if get_local_mouse_position().y < 280:
			$'..'.gui_disable_input = true 
		else:
			$'..'.gui_disable_input = false
			
func _set_focused(_focused : bool) -> void:
	print ("WARNING:  Attempting to set read-only var ColorPicker.Focused") 

func reposition() -> void:
	if rect_position.y >= 0: 
		rect_position.y = -284
		rect_size.x -= 4

func update_shaders() -> void:
	$'../R_Prev'.material.set_shader_param("color1", Color(0,color.g,color.b,1))
	$'../R_Prev'.material.set_shader_param("color2", Color(1,color.g,color.b,1))
	$'../G_Prev'.material.set_shader_param("color1", Color(color.r,0,color.b,1))
	$'../G_Prev'.material.set_shader_param("color2", Color(color.r,1,color.b,1))
	$'../B_Prev'.material.set_shader_param("color1", Color(color.r,color.g,0,1))
	$'../B_Prev'.material.set_shader_param("color2", Color(color.r,color.g,1,1))
	$'../A_Prev'.material.set_shader_param("color1", Color(color.r,color.g,color.b,0))
	$'../A_Prev'.material.set_shader_param("color2", Color(color.r,color.g,color.b,1))

func _on_ColorPicker_focus_entered() -> void:
	Focused = true 
func _on_ColorPicker_focus_exited() -> void:
	Focused = false

##  UPDATE THE HUE CIRCLE BASE COLOR ETC.
func _on_ColorPicker_color_changed(color : Color) -> void:
	update_shaders()
	
