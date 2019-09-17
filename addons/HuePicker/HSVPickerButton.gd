tool
extends Button

export(Color) var color setget set_color, get_color
signal color_changed(color)
export(bool) var enabled = true

var isReady = false

func set_color(value):
	color = value
	emit_signal('color_changed', value)

	if isReady == true:
		var lbl = $PopupPanel/Label
		lbl.text = "R: %.1f\nG: %.1f\nB: %.1f" % [color.r*255,color.g*255,color.b*255]

	if Engine.editor_hint == true and isReady == true:
		
		$ColorRect.color = color
		$ColorRect.self_modulate.a = color.a
		

func get_color():
	return color

func get_color_from_popup(color):  #Receiving the color from the hue picker
	self.color = color
	$ColorRect.color = color 
	$ColorRect.self_modulate.a = color.a
#	print ("modulating.. %s" % $ColorRect.self_modulate)

	emit_signal('color_changed', color)


#################################
func _ready():
	if color == null:  
		print ("HSVPickerButton:  No color defined?")
		color = ColorN('white')	
	$ColorRect.color = color
	isReady = true 

#	yield(get_tree(), "idle_frame")
	$PopupPanel/HuePicker.color = color

	set_meta("_editor_icon", preload("res://addons/HuePicker/icon_button_smol.png"))

#################################


func _on_HSVPickerButton_pressed():
	if not enabled == true:  return
	#Get quadrant I reside in so we can adjust the position of the popup.
	var quadrant = (get_viewport().size - rect_global_position)  / get_viewport().size
	quadrant.x = 1-round(quadrant.x); quadrant.y = 1-round(quadrant.y)

	var adjustment = Vector2(0,0)
	match quadrant:
		Vector2(0,0):  #Upper-left
#			print ("UL")
			adjustment.x += rect_size.x

		Vector2(1,0):  #Upper-right
#			print ("UR")
			adjustment.x = -$PopupPanel.rect_size.x

		Vector2(0,1):  #Lower-left
#			print ("LL")
			adjustment.x += rect_size.x
			adjustment.y = -$PopupPanel.rect_size.y

		Vector2(1,1):  #Lower-right
#			print ("LR")
			adjustment.x = -$PopupPanel.rect_size.x
			adjustment.y = -$PopupPanel.rect_size.y
			
	
	
	$PopupPanel.rect_position = rect_global_position + adjustment 
	$PopupPanel.popup()
	


func _on_PopupPanel_about_to_show():
	#Connect to the hue picker so we can succ its color
	$PopupPanel/HuePicker.connect('color_changed',self,"get_color_from_popup")

	#Bodge to correct the picker if the color was set here externally.
	$"PopupPanel/HuePicker/Hue Circle"._sethue(color.h,self)
	$PopupPanel/HuePicker._on_HuePicker_color_changed(color)
		
func _on_PopupPanel_popup_hide():
	#Disconnect from the hue picker
	$PopupPanel/HuePicker.disconnect('color_changed', self, "get_color_from_popup")
