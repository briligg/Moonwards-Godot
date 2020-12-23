extends Node
# Common helper functions

const SAVE_LOCATION : String = "user://Moonwards/user_settings.ini"
const SAVE_FOLDER : String = "user://Moonwards/"

var Enum = EnumHelper.new()

#The file that the player uses.
var user_file : ConfigFile = ConfigFile.new()

#These are the actions that are editable.
var editable_actions : Array = [
	"move_forwards", "move_backwards", "move_left", "move_right",
	"jump", "use", "toggle_first_person",
	"fly_up", "fly_down", "toggle_camera_fly", "mouse_toggle",
	"chat_toggle_size", "chat_page_up", "chat_page_down", "toggle_fly",
	"maneuver_lower", "maneuver_raise", "look_up", "look_down", "look_left",
	"look_right", "left_click"
]

#Whether the mouse is captured or not.
var is_capture_mode : bool = false setget ,is_mouse_captured

func _input(event):
	if event.is_action_pressed("mouse_toggle"):
		if is_capture_mode:
			capture_mouse(false)
		else:
			capture_mouse(true)

#Load the user file. Create it if it does not exist.
func _init() -> void :
	load_user_file()

#Decide whether the mouse should be captured or not.
func capture_mouse(capture_mouse : bool) -> void :
	if capture_mouse == true :
		is_capture_mode = true
		var viewport = get_tree().get_root()
		viewport.warp_mouse(viewport.size/2)
		yield(get_tree(), "idle_frame")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Signals.Menus.emit_signal("set_mouse_to_captured", true)
	
	else :
		is_capture_mode = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Signals.Menus.emit_signal("set_mouse_to_captured", false)

#Show the mouse and center it on the screen.
func center_mouse() -> void :
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#Let everything know that the mouse is now visible
	Signals.Menus.emit_signal("set_mouse_to_captured", false)

#Get an action from the InputMap. Returns string for InputEventType and it's action identifier.
func get_action(action_name : String) -> Array :
	var event : InputEvent = InputMap.get_action_list(action_name)[0]
	var event_type : String = "SomethingWentWrong"
	var scancode : int = 0
	if event is InputEventKey :
		scancode = event.scancode
		event_type = "Key"
	elif event is InputEventMouseButton : 
		scancode = event.button_index
		event_type = "MouseButton"
	
	return [event_type, scancode] 

#Return human readable format of the input.
func get_action_string(action_name : String) -> String :
	var event_scancode : int = get_action(action_name)[1]
	var event_string : String
	event_string = OS.get_scancode_string(event_scancode)
	return event_string

#Return true if the mouse is captured.
func is_mouse_captured() -> bool :
	return is_capture_mode

#Load the user file which stores all the player's personal settings.
func load_user_file() -> void :
	#Create the user file if it does not already exist.
	var dir : Directory = Directory.new()
	var is_default : bool = false #Don't recreate Events when using default.
	if not dir.file_exists(SAVE_LOCATION) :
		dir.make_dir("user://Moonwards/")
		var file : File = File.new()
		file.open(SAVE_LOCATION, file.WRITE)

		for action in editable_actions :
			var array : Array = get_action(action)
			file.store_string(("[%s]" % action) + "\n") #Section
			file.store_string(("event_type=\"%s\"" % array[0]) + "\n") 
			file.store_string(("scancode=%s" % array[1]) + "\n")

		file.close()
		is_default = true
	
	#Load the user file.
	user_file.load(SAVE_LOCATION)
	
	#Don't recreate actions if it is a default user file.
	if is_default :
		return
	
	#Start creating the InputEvents needed.
	for action in editable_actions :
		#Check that the file actually contains the action listed.
		if(user_file.has_section_key(action, "event_type") &&
				user_file.has_section_key(action, "scancode")) :
			var event : InputEvent
			var type : String = user_file.get_value(action, "event_type")
			if type == "Key" :
				event = InputEventKey.new()
				event.scancode = user_file.get_value(action, "scancode")
			elif type == "MouseButton" :
				event = InputEventMouseButton.new()
				event.button_index = user_file.get_value(action, "scancode")
			
			#Now replace the first event in the action with the custom event.
			var event_list : Array = InputMap.get_action_list(action)
			event_list.pop_front()
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			
			#Add the extra events at the end. These events are not meant to be changed.
			for extra_event in event_list :
				InputMap.action_add_event(action, extra_event)

#Save user info to the file.
func save_user_file() -> void :
	for action in editable_actions :
		var array = get_action(action)
		user_file.set_value(action, "event_type", array[0])
		user_file.set_value(action, "scancode", array[1])
	
	user_file.save(SAVE_LOCATION)

func reparent(node, new_parent, keep_world_pos = false):
	if node.get("global_transform") == null:
		keep_world_pos = false
	
	var pos = Vector3()
	if keep_world_pos: 
		pos = node.global_transform.origin
	var p = node.get_parent()
	p.remove_child(node)
	new_parent.add_child(node)
	node.owner = new_parent
	if keep_world_pos:
		node.global_transform.origin = pos
