tool
extends ColorPicker
signal _NeedManualClick(ev) #Tell parent the event was consumed, needs to pass a click

#Used to stop the Hue Circle and SatVal setters from an infinite update loop
var Focused  setget _Focused
func _on_ColorPicker_focus_entered():
	Focused = true 
func _on_ColorPicker_focus_exited():
	Focused = false
func _Focused():
	Print ("WARNING:  Attempting to set read-only var ColorPicker.Focused") 


func _ready():
#	connect("resized",self,"_resized")
	reposition()
func _draw():
#	VisualServer.canvas_item_set_clip(get_canvas_item(),true)
	reposition()




#If mouse lies outside our input capture zone, tell the viewport to disable our input.
func _gui_input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if get_local_mouse_position().y < 280:
			$'..'.gui_disable_input = true 
#			print("ignory")
		else:
			$'..'.gui_disable_input = false


	

#motherfucker don't you even THINK about repositioning yourself to 0 on me
func reposition():
	if rect_position.y >= 0: 
		rect_position.y = -284
		rect_size.x -= 4



func _resized():
	print(rect_position.y)

##  UPDATE THE HUE CIRCLE BASE COLOR ETC.
func _on_ColorPicker_color_changed(color):

#	#Prevent from accidentally resetting the internal hue if color's out of range
#	var c = Color(color.r, color.g, color.b, 1)
#	if c != ColorN('black', 1) and c != ColorN('white', 1) and c.s !=0:
#		$'../../../Hue Circle'._sethue(self.color.h, self)
#
#		$'../../..'.color = color 
#
##		$'../../..'._on_HuePicker_color_changed(color)
#		$'../../..'.emit_signal('color_changed', color)
#
#	$'../../..'.color.a = color.a

	#update the classic controls.
	update_shaders()
	
func update_shaders():
	$'../R_Prev'.material.set_shader_param("color1", Color(0,color.g,color.b,1))
	$'../R_Prev'.material.set_shader_param("color2", Color(1,color.g,color.b,1))
	$'../G_Prev'.material.set_shader_param("color1", Color(color.r,0,color.b,1))
	$'../G_Prev'.material.set_shader_param("color2", Color(color.r,1,color.b,1))
	$'../B_Prev'.material.set_shader_param("color1", Color(color.r,color.g,0,1))
	$'../B_Prev'.material.set_shader_param("color2", Color(color.r,color.g,1,1))
	$'../A_Prev'.material.set_shader_param("color1", Color(color.r,color.g,color.b,0))
	$'../A_Prev'.material.set_shader_param("color2", Color(color.r,color.g,color.b,1))
