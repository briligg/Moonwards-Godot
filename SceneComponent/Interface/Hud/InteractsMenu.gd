extends PanelContainer

#The button parent.
onready var button_parent : VBoxContainer = get_node("HBox/Buttons")
onready var description : RichTextLabel = get_node("HBox/DescriptionPanel/HBox/Description")

var button_relations : Array = []

#This is the current interactor component that has focus.
var interactor_component = null

#THe history of interactors.
var interactor_history : Array = []
var interactor_history_pointers : Array = []

#Listen for when interacts are possible.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self, "_new_interactor_append_to_history")

#Called from a signal. One of the buttons corresponding to the interactables has been pressed.
func _button_pressed(interactable : Node) -> void :
	#Interact with desired interactable
	interactor_component.on_interact_menu_request(interactable)

#Remove all buttons and their separators from the button parent.
#func _clear_button_parent() -> void :
#	description.text = ""
#
#	#Remove buttons and separators except for the top separator
#	var at : int = 0
#	for child in button_parent.get_children() :
#		if at != 0 :
#			child.queue_free()
#		at += 1

#Add a button to the InteractsMenu.
func _create_button(interact_name : String, info : String, interactable : Node) -> Button :
	#Create a separator to give buttons more space between each other.
	#Add constant override has to be deferred 
	#or else it will get overwritten by Godot.
	var child_count : int = button_parent.get_child_count() - 1
	if child_count != 0 :
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
	if child_count == 0 :
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

#Called from a signal. Adds a button to the button list based on the interactable.
func _interactable_entered(interactable_node) -> void :
	var button : Button = _create_button(interactable_node.get_title(), interactable_node.get_info(), interactable_node)
	button_relations.append([interactable_node, button])

#Called from a signal. Remove the button corresponding to the interactable from the button list.
func _interactable_left(interactable_node) -> void :
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
	
	#Remove the button from the scene tree.
	_free_button(button)
	
	#Remove the button relations entry.
	button_relations.remove(position_in_button_relations)
	
	#Clear the text description if there are no more interactables.
	if button_relations.empty() :
		description.text = ""

#Called from a signal. Disconnect the old interactor and connect the new one.
func _new_interactor(new_interactor : Node) -> void :
	if interactor_component != null :
#		interactor_component.lost_focus()
#		interactor_component.disconnect(interactor_component.FOCUS_ROLLBACK, self, "_rollback_interactor_focus")
		interactor_component.disconnect(interactor_component.INTERACTABLE_ENTERED_REACH, self, "_interactable_entered")
		interactor_component.disconnect(interactor_component.INTERACTABLE_LEFT_REACH, self, "_interactable_left")
#	new_interactor.connect(new_interactor.FOCUS_ROLLBACK, self, "_rollback_interactor_focus")
	new_interactor.connect(new_interactor.INTERACTABLE_ENTERED_REACH, self, "_interactable_entered")
	new_interactor.connect(new_interactor.INTERACTABLE_LEFT_REACH, self, "_interactable_left")
	interactor_component = new_interactor

#A new InteractorComponent has grabbed focus.
func _new_interactor_append_to_history(new_interactor : Node) -> void :
	_new_interactor(new_interactor)
	
	#Listen for when the interactor has been freed so we don't crash the game
	#by trying to call it after.
	new_interactor.connect("tree_exited", self, "interactor_freed", [new_interactor.get_instance_id()])
	
	interactor_history.append(new_interactor.get_instance_id())
	interactor_history_pointers.append(new_interactor)

#Called from a signal. Set the freed interactor contained in the history to null.
func interactor_freed(interactor_instance_id : int) -> void :
	interactor_history[interactor_history.find(interactor_instance_id)] = null

#Move the focus to the latest valid InteractorComponent.
#func _rollback_interactor_focus() -> void :
#	if interactor_history[interactor_history.size() -1] != null :
#		var interactor : Node = interactor_history_pointers[interactor_history.size() -1]
#		interactor.disconnect("tree_exited", self, "interactor_freed")
#	interactor_history.pop_back()
#	interactor_history_pointers.pop_back()
#
#	while interactor_history[interactor_history.size() -1] == null :
#		interactor_history.pop_back()
#		interactor_history_pointers.pop_back()
#
#	_new_interactor(interactor_history_pointers[interactor_history.size() -1])
