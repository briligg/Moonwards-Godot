extends Node


enum MODE {
	TOGGLE = 0,
	CONNECT = 1,
	DISCONNECT = 2
	}
	
signal logger(msg)

var scene setget , get_scene
func _ready():
	connect("logger", self, "_on_logger_call")

func _input(var event : InputEvent) -> void:
	if event.is_action_pressed("screenshot_key"):
		CreateScreenshot()
		
func bind_signal(signal_name : String, method : String, obj : Object, obj2 : Object, mode : int = 0) -> void:
	if method == "":
		method = str("_on_", signal_name)
		
	if mode == MODE.TOGGLE:  
		if obj.is_connected(signal_name, obj2, method):
			obj.disconnect(signal_name, obj2, method)
			emit_signal("logger", str("disconnect signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method))
		else:
			obj.connect(signal_name, obj2, method)
			emit_signal("logger", str("connect signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method))
	
	elif mode == MODE.CONNECT : #connect
		if not obj.is_connected(signal_name, obj2, method):
			obj.connect(signal_name, obj2, method)
		else:
			emit_signal("logger", str("tried to connect already connected signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method))
	
	elif mode == MODE.DISCONNECT : #disconnect
		if obj.is_connected(signal_name, obj2, method):
			obj.disconnect(signal_name, obj2, method)
			emit_signal("logger", str("disconnect signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method))
		else:
			emit_signal("logger", str("tried to disconnect a disconnected signal", signal_name," from ", str(obj)," to ", str(obj2), "::", method))


func CreateScreenshot() -> void:
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Let two frames pass to make sure the screen was captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Retrieve the captured image
	var image = get_viewport().get_texture().get_data()
	
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	var date_time = OS.get_datetime()
	image.save_png("user://screenshot_" + str(date_time.year) + str(date_time.month) + str(date_time.day) + str(date_time.hour) + str(date_time.minute) + str(date_time.second) + ".png")



func get_node_root(node : Node) -> Node:
	while node != null and (node.filename == null):
		node = node.get_parent()
	return node


func get_scene() -> Node:
	return get_tree().current_scene

######################################
#based on CernansDev.gd
#	get collision shapes created by plugin
#

func _on_logger_call(msg : String) -> void:
	Log.hint(self, "bind_signal", msg)




