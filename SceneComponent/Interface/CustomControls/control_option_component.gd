tool
extends HBoxContainer
export(String) var Label_text = "Default control name"  #setget update_title, get_title
var reading = false
var current_scancode = null
onready var titlelabel = get_node("Label")

#This is emitted when a new input is confirmed.
signal new_input_confirmed()

#What action to edit when setting input.
export var action_to_edit : String = "action_name"

func update_labels():
	#Do not do anything if I am a defunct button.
	if current_scancode == null :
		return
	
	#Updates text from labels
	var event : InputEventKey = InputMap.get_action_list(action_to_edit)[0]
	var scancode : String = OS.get_scancode_string(event.scancode)
	get_node("Button").text = scancode
	get_node("Confirm/CenterContainer/Label2").text = scancode
	
func get_title():
	return Label_text
	
func update_title(text):
	if(Engine.is_editor_hint()):
		Label_text = text
		$Label.text = text

func _enter_tree() -> void:
	var is_key = false
	if not $Confirm.get_cancel().is_connected("pressed",self,"_on_Cancel"):
		$Confirm.get_cancel().connect("pressed",self,"_on_Cancel") 
	#Get the popup cancel button and connect it to _on_cancel
	
	$Label.text = get_title()
	titlelabel = get_title()
	if InputMap.has_action(str(name)):
		for members in range(0,InputMap.get_action_list(str(name)).size()):
			if InputMap.get_action_list(str(name))[members] is InputEventKey:
				current_scancode = InputMap.get_action_list(str(name))[members].scancode
				is_key = true
				break
		if is_key:	
			update_labels()
			#Get the first action asociated with this input
			get_node("Button").disabled = false
		


func _unhandled_input(event):
	if event is InputEventKey and reading:
		current_scancode = event.scancode
		get_node("Confirm/CenterContainer/Label2").text = OS.get_scancode_string(current_scancode)
		

func _on_change_control_pressed():
	#Opens the popup and starts reading from the keyboard
	$Confirm.popup_centered()
	reading = true



func _on_Popup_confirmed():
	var Event = InputEventKey.new()
	Event.scancode = current_scancode
	var event_list : Array = InputMap.get_action_list(str(name))
	
	InputMap.action_erase_events(str(action_to_edit))
	InputMap.action_add_event (str(action_to_edit), Event)
	
	#Re add any extra events at the end.
	event_list.pop_front()
	for extra_event in event_list :
		InputMap.action_add_event(str(action_to_edit), extra_event)
	
	get_node("Button").text = OS.get_scancode_string(current_scancode)
	update_labels()
	reading = false


func _on_Confirm_popup_hide():
	reading = false
	#Stop reading keyboard input if the popup has closed
