extends PanelContainer

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
	for child in get_children() :
		child.queue_free()

func _create_button(interact_name : String, interactable_location : int) -> void :
	var new_button : Button = Button.new()
	new_button.name = interact_name
	new_button.text = interact_name
	
	call_deferred("add_child", new_button)
	
	#Listen for the button to be interacted wit.
	new_button.connect("pressed", self, "_button_pressed", [interactable_location])

func _show_interacts(potential_interacts : Array) :
	interact_list = potential_interacts
	show()
	
	#Create a button for each potential interact.
	var at : int = 0
	for interactable in potential_interacts :
		_create_button(interactable.name, at)
		at += 1
