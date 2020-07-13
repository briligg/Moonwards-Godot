extends Node2D

class Line:
	var start: Vector3
	var end: Vector3
	var line_color: Color
	var time: float
	
	func _init(_start: Vector3, _end: Vector3, _line_color: Color, _time: float) -> void:
		self.start = _start
		self.end = _end
		self.line_color = _line_color
		self.time = _time

var lines: = []
var removed_line: = false


func _process(delta: float) -> void:
	for i in range(len(lines)):
		lines[i].time -= delta
	
	if(len(lines) > 0 || removed_line):
		update() # calls _draw
		removed_line = false


func _draw() -> void:
	var _cam: Camera = get_viewport().get_camera()
	for i in range(len(lines)):
		var screen_point_start: Vector2 = _cam.unproject_position(lines[i].start)
		var screen_point_end: Vector2 = _cam.unproject_position(lines[i].end)
		
		# Dont draw line if either start or end is considered behind the camera
		# this causes the line to not be drawn sometimes (flicker) but avoids a bug where the
		# line is drawn incorrectly
		if(_cam.is_position_behind(lines[i].start) ||
			_cam.is_position_behind(lines[i].end)):
			continue
		
		draw_line(screen_point_start, screen_point_end, lines[i].line_color)
	
	# Remove lines that have timed out
	var i: int = lines.size() - 1
	while (i >= 0):
		if(lines[i].time < 0.0):
			lines.remove(i)
			removed_line = true
		i -= 1

func c_draw_line(start: Vector3, end: Vector3, line_color: Color, time: float = 0.0) -> void:
	lines.append(Line.new(start, end, line_color, time))

func c_draw_ray(start: Vector3, ray: Vector3, line_color: Color, time: float = 0.0) -> void:
	lines.append(Line.new(start, start + ray, line_color, time))

func c_draw_cube(center: Vector3, half_extents: float, line_color: Color, time: float = 0.0) -> void:
	# Start at the 'top left'
	var line_point_start: Vector3 = center
	line_point_start.x -= half_extents
	line_point_start.y += half_extents
	line_point_start.z -= half_extents
	
	#Draw top square
	var line_point_end: Vector3 = line_point_start + Vector3(0, 0, half_extents * 2.0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	line_point_start = line_point_end
	line_point_end = line_point_start + Vector3(half_extents * 2.0, 0, 0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	line_point_start = line_point_end
	line_point_end = line_point_start + Vector3(0, 0, -half_extents * 2.0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	line_point_start = line_point_end
	line_point_end = line_point_start + Vector3(-half_extents * 2.0, 0, 0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	
	#Draw bottom square
	line_point_start = line_point_end + Vector3(0, -half_extents * 2.0, 0)
	line_point_end = line_point_start + Vector3(0, 0, half_extents * 2.0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	line_point_start = line_point_end
	line_point_end = line_point_start + Vector3(half_extents * 2.0, 0, 0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	line_point_start = line_point_end
	line_point_end = line_point_start + Vector3(0, 0, -half_extents * 2.0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	line_point_start = line_point_end
	line_point_end = line_point_start + Vector3(-half_extents * 2.0, 0, 0)
	c_draw_line(line_point_start, line_point_end, line_color, time);
	
	#Draw vertical lines
	line_point_start = line_point_end
	c_draw_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
	line_point_start += Vector3(0, 0, half_extents * 2.0)
	c_draw_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
	line_point_start += Vector3(half_extents * 2.0, 0, 0)
	c_draw_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
	line_point_start += Vector3(0, 0, -half_extents * 2.0)
	c_draw_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
