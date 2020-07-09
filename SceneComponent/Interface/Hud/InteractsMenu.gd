extends PanelContainer

#The button parent.
onready var button_parent : VBoxContainer = get_node("HBox/Buttons")
onready var description : RichTextLabel = get_node("HBox/DescriptionPanel/HBox/Description")

var interact_list : Array = []

var enter_comes_first : bool = false

#Listen for when interacts are possible.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.POTENTIAL_INTERACT_REQUESTED, self, "_show_interacts")
	Signals.Hud.connect(Signals.Hud.INTERACTABLE_ENTERED_REACH, self, "_interactable_entered")
	Signals.Hud.connect(Signals.Hud.INTERACTABLE_LEFT_REACH, self, "_interactable_left")

#One of the buttons corresponding to the interactables has been pressed.
func _button_pressed(interactable_location_in_list : int) -> void :
	#Interact with desired interactable
	var signal_string : String = Signals.Hud.INTERACT_OCCURED
	var interactable = interact_list[interactable_location_in_list]
	Signals.Hud.emit_signal(signal_string, interactable)

#Remove all buttons from the button parent.
func _clear_button_parent() -> void :
	description.text = ""
	
	#Remove buttons and separators.
	for child in button_parent.get_children() :
		child.queue_free()

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

func _free_button(button_location_in_interact_list : int) -> void :
	var  at : int = button_location_in_interact_list
	if at == 0 : #First button does not have an HSperarator above it.
		#Remove the top button and the HSeparator beneath it.
		at = 1
	else :
		at *= 2
	
	#Remove the button for the interactable and the HSeparator node.
	if button_parent.get_child_count() > 1 :
		button_parent.get_child(at).queue_free()
	button_parent.get_child(at-1).queue_free()

func _interactable_entered(interactable_node) -> void :
	interact_list.append(interactable_node)
	_create_button(interactable_node.name, interact_list.size()-1, interactable_node.get_info())
	enter_comes_first = true

func _interactable_left(interactable_node) -> void :
	assert(enter_comes_first)
	
	#Get where the interactable was originally in the list.
	var at : int = interact_list.find(interactable_node)
	#Remove myself from the interact_list.
	interact_list.remove(at)
	
	_free_button(at)
	
	enter_comes_first = false

#Called from a signal. The player wants to see what interactables are present.
func _show_interacts(potential_interacts : Array) :
	#Hide if I am already visible.
	if visible == true :
		visible = false
		return
	
	interact_list = potential_interacts
	interact_list.empty()
	_clear_button_parent()
	show()
	
	#Make the mouse appear
	Helpers.capture_mouse(false)
	
	#Create a button for each potential interact.
	var at : int = 0
	for interactable in potential_interacts :
		_create_button(interactable.name, at, interactable.get_info())
		at += 1
