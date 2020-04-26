tool
extends Control

const SQ22 : float = 0.70710678118654752440084436210485  #Sqrt(2)/2

enum DRAGTYPE {
			NONE,
			HUE,
			XY
			}
			
onready var indicator_h = $indicator_h
onready var indicator = $"indicator_rgba"
onready var color_rect = $ColorRect
onready var sat_val = $ColorRect/SatVal
onready var parent = get_parent()
onready var indicator_bg = $"indicator_rgba/bg"
var UsefulFunctions : Reference = preload("res://Tree/addons/HuePicker/HuePickerUtils.gd").new()


var short_edge : float = min(rect_size.x, rect_size.y)
var outR : float = short_edge * 0.5  #Outer Radius
var inR : float = short_edge * 0.4 #0.375
var midR : float = short_edge * 0.4375
var Dragging : int

#We need to save the hue in case value is zeroed out and resets it
var saved_h : float = 0 setget set_hue, get_hue


#
#func _init() -> void:
#	UsefulFunctions = UsefulFunctions.new()

func _ready() -> void:
	update()

func _draw() -> void:
	var rgb : Color  #Color()
	short_edge = min(rect_size.x, rect_size.y)
	outR = short_edge * 0.5  #Outer Radius
	inR = short_edge * 0.4 #0.375
	midR = short_edge * 0.4375



	#square width, pos
	var sqw = inR * 2 * SQ22
#	var sqpos = int(inR * SQ22)

	var x = rect_size.x/2 #+ SQ22
	var y = rect_size.y/2 #+ SQ22

	
	#Draw the wheel
	draw_circle(Vector2(x,y),outR+1.5, Color(0,0,0,0.3))

	for theta in range(720):
		var i = deg2rad(theta/2.0)

		rgb = UsefulFunctions.HSVtoRGB(theta / 720.0, 1.0, 0.5)
		
		draw_line(Vector2(x + cos(i) * inR, y + sin(i) * inR),
				  Vector2(x + cos(i + PI/12.0) * outR, y + sin(i + PI/12.0) * outR),
				  rgb,rect_size.x/64,true)
	
	
	#Reposition stuff
	color_rect.rect_size = Vector2(sqw, sqw)
	color_rect.rect_position = Vector2(rect_size.x/2 - sqw/2+1,  rect_size.y/2 - sqw/2+1)
	
	reposition_hue_indicator()
	var chunk = Vector2(short_edge,short_edge)
	
	indicator.rect_size = chunk / 8
	indicator_bg.position = chunk / 16
	indicator_bg.scale = chunk / 256
	indicator.rect_position.x = rect_size.x/2 - short_edge/2
	indicator.rect_position.y = rect_size.y/2 + short_edge/2 - indicator.rect_size.y
	
func set_hue(value : float) -> void:
	saved_h = value
func get_hue() -> float:
	return saved_h

func reposition_hue_indicator() -> void:
	indicator_h.rect_pivot_offset = Vector2(indicator_h.rect_size.x / 2,
											 indicator_h.rect_size.y / 2)
	indicator_h.rect_size.y = outR - inR * 0.95
	indicator_h.rect_size.x = short_edge / 25

	var ctr = short_edge * 0.45 #Center ring
	var ihx  = ctr*cos(saved_h * 2*PI) + rect_size.x/2 - $indicator_h.rect_size.x/2 
	var ihy  = ctr*sin(saved_h * 2*PI) + rect_size.y/2 - $indicator_h.rect_size.y/2 
	indicator_h.rect_position = Vector2(ihx,ihy)

	#Reposition SatVal indicator
	color_rect.get_node("indicator_sv").position = Vector2(parent.color.s,
											 1-parent.color.v) * color_rect.rect_size
	
	
#func _input(event):  #maybe _input instead if updating doesn't work?
#	if Input.is_mouse_button_pressed(BUTTON_LEFT):
#		print(event)
#		update()
#
#
	
	

############## SIGNALS ###############################

func _gui_input(ev : InputEvent) -> void:
	var mpos = get_local_mouse_position()

	if ev is InputEventMouseButton:
		if ev.pressed == true and ev.button_index == BUTTON_LEFT:  #MouseDown
			if color_rect.get_rect().has_point(mpos):
				Dragging = DRAGTYPE.XY
			else:
				Dragging = DRAGTYPE.HUE

	#Drag
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and Dragging == DRAGTYPE.HUE:
		var angle = (rad2deg(mpos.angle_to_point(rect_size/2)+2*PI) ) / 360

		#A workaround for a bug in Godot 3.0.2 where setting HSV properties resets alpha.
		var alpha = parent.color.a

		parent.color.h = angle
		saved_h = angle

		parent.color.a = alpha  #Put alpha component back
		
	elif Input.is_mouse_button_pressed(BUTTON_LEFT) and Dragging == DRAGTYPE.XY:
		var pos = sat_val.get_local_mouse_position()
		var s = pos.x /  sat_val.rect_size.x
		var v = pos.y /  sat_val.rect_size.y

		#A workaround for a bug in Godot 3.0.2 where setting HSV properties resets alpha.
		var alpha = parent.color.a
			
		parent.color.h = saved_h  #fixy?
		parent.color.s = clamp(s, 0.0, 1.0)
		parent.color.v = clamp(1-v, 0.0, 1.0)

		parent.color.a = alpha  #Put alpha component back
	
	if ev is InputEventMouseButton:		
		if ev.button_index == BUTTON_LEFT and ev.pressed == false:  #MouseUp
			Dragging = DRAGTYPE.NONE
		else:
			update()
