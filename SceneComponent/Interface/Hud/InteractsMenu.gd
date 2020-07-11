extends PanelContainer

#The button parent.
onready var button_parent : VBoxContainer = get_node("HBox/Buttons")
onready var description : RichTextLabel = get_node("HBox/DescriptionPanel/HBox/Description")

var interact_list : Array = []

#Listen for when interacts are possible.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.POTENTIAL_INTERACT_REQUESTED, self, "_show_interacts")
	Signals.Hud.connect(Signals.Hud.INTERACTABLE_ENTERED_REACH, self, "_interactable_entered")
	Signals.Hud.connect(Signals.Hud.INTERACTABLE_LEFT_REACH, self, "_interactable_left")

#Called from a signal. One of the buttons corresponding to the interactables has been pressed.
func _button_pressed(interactable_location_in_list : int) -> void :
	#Interact with desired interactable
	var signal_string : String = Signals.Hud.INTERACT_OCCURED
	var interactable = interact_list[interactable_location_in_list]
	Signals.Hud.emit_signal(signal_string, interactable)

#Remove all buttons and their separators from the button parent.
func _clear_button_parent() -> void :
	description.text = ""
	
	#Remove buttons and separators except for the top separator
	var at : int = 0
	for child in button_parent.get_children() :
		if at != 0 :
			child.queue_free()
		at += 1

#Convert the interactor list location into a location that will return a button from button parent.
func _convert_to_button_location(interactor_list_location : int) -> int :
	var  at : int = interactor_list_location
	at += 1
	at *= 2
	at -= 1
	return at

#Add a button to the InteractsMenu.
func _create_button(interact_name : String, interactable_location : int, info : String) -> void :
	#Create a separator to give buttons more space between each other.
	#Add constant override has to be deferred 
	#or else it will get overwritten by Godot.
	var separator : HSeparator = HSeparator.new()
	separator.call_deferred("add_constant_override", "separation", 15)
	separator.set("separation", true)
	if interactable_location != 0 :
		button_parent.call_deferred("add_child", separator)
	
	#Create a button.
	var new_button : Button = Button.new()
	new_button.name = interact_name
	new_button.text = interact_name
	new_button.focus_mode = new_button.FOCUS_ALL
	button_parent.call_deferred("add_child", new_button)
	
	#Grab focus if we are the first button to be created.
	if interactable_location == 0 :
		new_button.call_deferred("grab_focus")
	
	#Listen for the button to be interacted with.
	new_button.connect("pressed", self, "_button_pressed", [interactable_location])
	new_button.connect("mouse_entered", self, "_display_button_info", [info])
	new_button.connect("focus_entered", self, "_display_button_info", [info])

#Called from a signal. Shows the info of the interactable.
func _display_button_info(button_info : String) -> void :
	description.text = button_info

#Remove a specific button from the button list.
func _free_button(button_location_in_interact_list : int) -> void :
	var at : int = _convert_to_button_location(button_location_in_interact_list)
	
	#Remove the button for the interactable and the HSeparator node.
	button_parent.get_child(at).queue_free()
	if at > 1 :
		button_parent.get_child(at-1).queue_free()
		
	#Remove the separator above the button underneath if we are removing the first button.
	elif button_parent.get_child_count() > 2 :
		button_parent.get_child(at+1).queue_free()

#Get a button Node from the buttons list.
func _get_button(location_in_interact_list : int) -> Button :
	var at : int = _convert_to_button_location(location_in_interact_list)
	
	var return_button : Button = button_parent.get_child(at)
	return return_button

#Called from a signal. Adds a button to the button list based on the interactable.
func _interactable_entered(interactable_node) -> void :
	interact_list.append(interactable_node)
	_create_button(interactable_node.get_title(), interact_list.size()-1, interactable_node.get_info())

#Called from a signal. Remove the button corresponding to the interactable from the button list.
func _interactable_left(interactable_node) -> void :
	#Get where the interactable was originally in the list.
	var at : int = interact_list.find(interactable_node)
	
	#Move focus to another button if there is one.
	var button : Button = _get_button(at)
	if button.has_focus() && button_parent.get_child_count() > 1 :
		if button_parent.get_child(1).has_focus() == false :
			button_parent.get_child(1).grab_focus()
		elif button_parent.get_child_count() >= 4 :
			button_parent.get_child(3).grab_focus()
	
	#Remove myself from the interact_list.
	interact_list.remove(at)
	
	_free_button(at)
	
	#Clear the text description if there are no more interactables.
	if interact_list.empty() :
		description.text = ""

#Called from a signal. The player wants to see what interactables are present.
func _show_interacts(potential_interacts : Array) :
	#Hide if I am already visible.
	if visible == true :
		visible = false
		return
	
	interact_list = potential_interacts
	_clear_button_parent()
	show()
	
	#Make the mouse appear
	Helpers.capture_mouse(false)
	
	#Create a button for each potential interact.
	var at : int = 0
	for interactable in potential_interacts :
		_create_button(interactable.get_title(), at, interactable.get_info())
		at += 1
