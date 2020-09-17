extends PanelContainer

#The button parent.
onready var button_parent : VBoxContainer = get_node("HBox/Buttons")
onready var description : RichTextLabel = get_node("HBox/DescriptionPanel/HBox/Description")

var button_relations : Array = []

#This is the current interactor component that has focus.
var interactor_component : InteractorComponent = null

#THe history of interactors.
var interactor_history : Array = []
var interactor_history_pointers : Array = []

#Listen for when interacts are possible.
func _ready() -> void :
	pass
#	Signals.Hud.connect(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self, "_new_interactor")

#Called from a signal. One of the buttons corresponding to the interactables has been pressed.
func _button_pressed(interactable : Node) -> void :
	#Interact with desired interactable
	interactor_component.menu_interact_request(interactable)

#Remove all buttons and separators for Interactables.
func _clear_button_parent() -> void :
	#Disconnect all signals that are connected.
	for array in button_relations :
		var interactable = array[0]
		interactable.disconnect("display_info_changed", self, "_interactable_display_info_changed")
		interactable.disconnect("title_changed", self, "_interactable_title_changed")
	
	var child_index : int = button_parent.get_child_count() - 1
	while child_index > 0 :
		button_parent.get_child(child_index).queue_free()
		child_index -= 1
	
	button_relations = []

#Add a button to the InteractsMenu.
func _create_button(interact_name : String, info : String, interactable : Interactable) -> Button :
	#Create a separator to give buttons more space between each other.
	#Add constant override has to be deferred 
	#or else it will get overwritten by Godot.
	if not button_relations.empty() :
		var separator : HSeparator = HSeparator.new()
		separator.call_deferred("add_constant_override", "separation", 15)
		separator.set("separation", true)
		button_parent.call_deferred("add_child", separator)
	
	#Create a button.
	var new_button : Button = Button.new()
	new_button.name = interact_name
	new_button.text = interact_name
	new_button.focus_mode = new_button.FOCUS_ALL
	button_parent.call_deferred("add_child", new_button)
	
	#Grab focus if we are the first button to be created.
	if button_relations.empty() :
		new_button.call_deferred("grab_focus")
	
	#Listen for the button to be interacted with.
	new_button.connect("pressed", self, "_button_pressed", [interactable])
	new_button.connect("mouse_entered", self, "_display_button_info", [info])
	new_button.connect("focus_entered", self, "_display_button_info", [info])
	
	return new_button

#Called from a signal. Shows the info of the interactable.
func _display_button_info(button_info : String) -> void :
	description.text = button_info

#Remove a specific button from the button list.
func _free_button(button : Button) -> void :
	#Remove the button for the interactable and the HSeparator node.
	var at : int = button.get_position_in_parent()
	button.queue_free()
	if at > 1 :
		button_parent.get_child(at-1).queue_free()
		
	#Remove the separator above the button underneath if we are removing the first button.
	elif button_parent.get_child_count() > 2 :
		button_parent.get_child(at+1).queue_free()

#Bring up the interacts menu if the player requests it.
func _input(event : InputEvent) -> void :
	if event.is_action_pressed("use") :
		if visible :
			visible = false
		else :
			Helpers.capture_mouse(false)
			visible = true

#Called from Interactable signal. Update a buttons display text.
func _interactable_display_info_changed(new_display_info : String, button : Button) -> void :
	button.disconnect("mouse_entered", self, "_display_button_info")
	button.disconnect("focus_entered", self, "_display_button_info")
	button.connect("mouse_entered", self, "_display_button_info", [new_display_info])
	button.connect("focus_entered", self, "_display_button_info", [new_display_info])
	
	#Update the info display if the button has focus.
	if button.has_focus() :
		description.text = new_display_info

#Called from a signal. Adds a button to the button list based on the interactable.
func _interactable_entered(interactable_node : Interactable) -> void :
	#Check that the Interctable is not already listed.
	for array in button_relations :
		if array[0] == interactable_node :
			return
	
	var button : Button = _create_button(interactable_node.get_title(), interactable_node.get_info(), interactable_node)
	button_relations.append([interactable_node, button])
	
	#Listen for when Interactable attributes have been changed.
	interactable_node.connect("display_info_changed", self, "_interactable_display_info_changed", [button])
	interactable_node.connect("title_changed", self, "_interactable_title_changed", [button])

#Called from a signal. Remove the button corresponding to the interactable from the button list.
func _interactable_left(interactable_node : Interactable) -> void :
	#Move focus to another button if there is one.
	var button : Button
	var position_in_button_relations : int = 0
	var at : int = 0
	for array in button_relations :
		if array.has(interactable_node) :
			button = array[1]
			position_in_button_relations = at
		at += 1
	
	#If this crashes, it is because something went wrong with the button relations creation.
	if button.has_focus() && button_parent.get_child_count() > 1 :
		if button_parent.get_child(1).has_focus() == false :
			button_parent.get_child(1).grab_focus()
		elif button_parent.get_child_count() >= 4 :
			button_parent.get_child(3).grab_focus()
	
	#Stop listening to the Interactables signals.
	interactable_node.disconnect("display_info_changed", self, "_interactable_display_info_changed")
	interactable_node.disconnect("title_changed", self, "_interactable_title_changed")
	
	#Remove the button from the scene tree.
	_free_button(button)
	
	#Remove the button relations entry.
	button_relations.remove(position_in_button_relations)
	
	#Clear the text description if there are no more interactables.
	if button_relations.empty() :
		description.text = ""

func _interactable_title_changed(new_title : String, button : Button) -> void :
	button.text = new_title

#Called from a signal. Disconnect the old interactor and connect the new one.
func _new_interactor(new_interactor : InteractorComponent) -> void :
	if interactor_component != null :
		interactor_component.lost_focus()
#		interactor_component.disconnect(interactor_component.FOCUS_ROLLBACK, self, "_rollback_interactor_focus")
		interactor_component.disconnect(interactor_component.INTERACTABLE_ENTERED_REACH, self, "_interactable_entered")
		interactor_component.disconnect(interactor_component.INTERACTABLE_LEFT_REACH, self, "_interactable_left")
		
		#Clear whatever Interactables are present from the old Interactor.
		_clear_button_parent()
		
#	new_interactor.connect(new_interactor.FOCUS_ROLLBACK, self, "_rollback_interactor_focus")
	new_interactor.connect(new_interactor.INTERACTABLE_ENTERED_REACH, self, "_interactable_entered")
	new_interactor.connect(new_interactor.INTERACTABLE_LEFT_REACH, self, "_interactable_left")
	interactor_component = new_interactor
	
	#Add the new Interactables to the scene tree.
	for interactable in new_interactor.get_interactables() :
		_interactable_entered(interactable)
