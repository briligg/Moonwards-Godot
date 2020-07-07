extends PanelContainer

#The button parent.
onready var button_parent : VBoxContainer = get_node("HBox/Buttons")

var interact_list : Array = []

#Listen for when interacts are possible.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.POTENTIAL_INTERACT_REQUESTED, self, "_show_interacts")

func _button_pressed(interactable_location_in_list : int) -> void :
	#Interact with desired interactable
	var signal_string : String = Signals.Hud.INTERACT_OCCURED
	var interactable = interact_list[interactable_location_in_list]
	Signals.Hud.emit_signal(signal_string, interactable)
	
	#Close the menu.
	hide()
	for child in button_parent.get_children() :
		child.queue_free()

func _create_button(interact_name : String, interactable_location : int, info : String) -> void :
	var new_button : Button = Button.new()
	new_button.name = interact_name
	new_button.text = interact_name
	
	button_parent.call_deferred("add_child", new_button)
	
	#Listen for the button to be interacted with.
	new_button.connect("pressed", self, "_button_pressed", [interactable_location])
	new_button.connect("mouse_entered", self, "_display_button_info", [info])
	new_button.connect("focus_entered", self, "_display_button_info", [info])

func _display_button_info(button_info : String) -> void :
	$HBox/Description.text = button_info

func _show_interacts(potential_interacts : Array) :
	interact_list = potential_interacts
	show()
	
	#Create a button for each potential interact.
	var at : int = 0
	for interactable in potential_interacts :
		_create_button(interactable.name, at, interactable.get_info())
		at += 1
