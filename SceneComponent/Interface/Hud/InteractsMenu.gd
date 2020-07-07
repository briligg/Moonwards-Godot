extends PanelContainer

#The button parent.
onready var button_parent : VBoxContainer = get_node("HBox/Buttons")
onready var description : RichTextLabel = get_node("HBox/Description")

var interact_list : Array = []

#Listen for when interacts are possible.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.POTENTIAL_INTERACT_REQUESTED, self, "_show_interacts")

#One of the buttons corresponding to the interactables has been pressed.
func _button_pressed(interactable_location_in_list : int) -> void :
	#Interact with desired interactable
	var signal_string : String = Signals.Hud.INTERACT_OCCURED
	var interactable = interact_list[interactable_location_in_list]
	Signals.Hud.emit_signal(signal_string, interactable)
	
	#Close the menu and erase the buttons.
	hide()
	_clear_button_parent()

func _clear_button_parent() -> void :
	description.text = ""
	
	#Remove buttons and separators except for the top separator.
	var at : int = 0
	for child in button_parent.get_children() :
		if at != 0 :
			child.queue_free()
		
		at += 1

#Add a button to the InteractsMenu.
func _create_button(interact_name : String, interactable_location : int, info : String) -> void :
	#Create a separator to give buttons more space between each other.
	#Add constant override has to be deferred 
	#or else it will get overwritten by Godot.
	var separator : HSeparator = HSeparator.new()
	separator.call_deferred("add_constant_override", "separation", 15)
	separator.set("separation", true)

	#Do not add the separator if you are first in the list.
	if interactable_location != 0 :
		button_parent.call_deferred("add_child", separator)
	
	#Create a button.
	var new_button : Button = Button.new()
	new_button.name = interact_name
	new_button.text = interact_name
	button_parent.call_deferred("add_child", new_button)
	
	#Listen for the button to be interacted with.
	new_button.connect("pressed", self, "_button_pressed", [interactable_location])
	new_button.connect("mouse_entered", self, "_display_button_info", [info])
	new_button.connect("focus_entered", self, "_display_button_info", [info])

func _display_button_info(button_info : String) -> void :
	description.text = button_info

func _show_interacts(potential_interacts : Array) :
	interact_list = potential_interacts
	_clear_button_parent()
	show()
	
	#Create a button for each potential interact.
	var at : int = 0
	for interactable in potential_interacts :
		_create_button(interactable.name, at, interactable.get_info())
		at += 1
