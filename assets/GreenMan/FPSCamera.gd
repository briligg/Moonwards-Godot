extends Camera

# class member variables go here, for example:
# var a = 2
var yaw = 0.0
var pitch = 0.0
var view_sensitivity 
var restrictaxis = false
var originaltranslation = Vector3()
var originalrotation = Vector3()
var time = 0.0
var Znoice = 0.0
var Zholder = 0.0
var v_off = 0.0

func _ready():
	set_process_input(true)
	originaltranslation = Vector3(translation.x,translation.y,translation.z)
	originalrotation = Vector3(rotation_degrees.x,rotation_degrees.y,rotation_degrees.z)

func bobbing_effect(time, speed, delta):
	if speed >= 0.1 and get_parent().get_parent().is_on_floor():
		var Oscillation = sin(time * speed*3.1416)
		
		v_offset = clamp(v_offset + delta*0.5*Oscillation, -0.2,0.2)
		#calculate_z_rotation(Oscillation, delta)
		
		
	else:
		if v_offset < -0.001:
			v_offset += 0.01
		if v_offset > 0.001:
			v_offset -= 0.01
		if rotation_degrees.z < -0.01:
			Znoice += 10*delta
		if rotation_degrees.z > 0.01:
			Znoice -= 10*delta
		else: 
			pass
		
		

func _input(ev):
	view_sensitivity = get_node("../..").view_sensitivity
	if (ev is InputEventMouseMotion):
		yaw = yaw - ev.relative.x * view_sensitivity
		if restrictaxis:
			pitch = clamp(pitch - ev.relative.y * view_sensitivity,0,0)
		else:
			pitch = clamp(pitch - ev.relative.y * view_sensitivity,-89,89)
		get_parent().rotation_degrees.x = pitch
		get_parent().rotation_degrees.y = yaw
func _process(delta):
	time += delta
	bobbing_effect(time, get_parent().get_parent().hspeed, delta)
	
func calculate_z_rotation(Oscc, delta):
	
	
		rotation_degrees.z = Znoice*delta