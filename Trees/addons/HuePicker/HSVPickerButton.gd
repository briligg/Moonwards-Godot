tool
extends Button
signal color_changed(color)
 
export(Color) var color setget hue_set_color
export(bool) var enabled = true

onready var color_rect : ColorRect = $ColorRect
onready var popup : PopupPanel= $PopupPanel
onready var picker = picker

var isReady = false

func _ready() -> void:
	if color == null:  
		print ("HSVPickerButton:  No color defined?")
		color = ColorN('white')	
	color_rect.color = color
	isReady = true 

#	yield(get_tree(), "idle_frame")
	picker.color = color

	set_meta("_editor_icon", preload("res://Trees/addons/HuePicker/icon_button_smol.png"))


func hue_set_color(value : Color) -> void:
	color = value
	emit_signal('color_changed', value)

	if isReady == true:
		var lbl = popup.get_node("Label")
		lbl.text = "R: %.1f\nG: %.1f\nB: %.1f" % [color.r*255,color.g*255,color.b*255]

	if Engine.editor_hint == true and isReady == true:
		
		color_rect.color = color
		color_rect.self_modulate.a = color.a
		

func get_color_from_popup(color : Color) -> void:  #Receiving the color from the hue picker
	self.color = color
	color_rect.color = color 
	color_rect.self_modulate.a = color.a
#	print ("modulating.. %s" % $ColorRect.self_modulate)

	emit_signal('color_changed', color)

func _on_HSVPickerButton_pressed() -> void:
	if not enabled == true:  return
	#Get quadrant I reside in so we can adjust the position of the popup.
	var quadrant : Vector2 = (get_viewport().size - rect_global_position)  / get_viewport().size
	quadrant.x = 1-round(quadrant.x); quadrant.y = 1-round(quadrant.y)

	var adjustment : Vector2 = Vector2(0,0)
	match quadrant:
		Vector2(0,0):  #Upper-left
#			print ("UL")
			adjustment.x += rect_size.x

		Vector2(1,0):  #Upper-right
#			print ("UR")
			adjustment.x = -popup.rect_size.x

		Vector2(0,1):  #Lower-left
#			print ("LL")
			adjustment.x += rect_size.x
			adjustment.y = -popup.rect_size.y

		Vector2(1,1):  #Lower-right
#			print ("LR")
			adjustment.x = -popup.rect_size.x
			adjustment.y = -popup.rect_size.y
			
	
	
	popup.rect_position = rect_global_position + adjustment 
	popup.popup()
	

func _on_PopupPanel_about_to_show() -> void:
	#Connect to the hue picker so we can succ its color
	picker.connect('color_changed',self,"get_color_from_popup")

	#Bodge to correct the picker if the color was set here externally.
	picker.get_node("HueCircle")._sethue(color.h)
	picker._on_HuePicker_color_changed(color)
		
func _on_PopupPanel_popup_hide() -> void:
	#Disconnect from the hue picker
	picker.disconnect('color_changed', self, "get_color_from_popup")
