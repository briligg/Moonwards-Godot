extends PanelContainer

#The button parent.
onready var button_parent : VBoxContainer = get_node("HBox/AnchorTransfer/Buttons")
onready var description : RichTextLabel = get_node("HBox/DescriptionPanel/HBox/Description")

var interactables : Array  = []

#This is the current interactor component that has focus.
var interactor_component : InteractorComponent = null

#THe history of interactors.
var interactor_history : Array = []
var interactor_history_pointers : Array = []

#This determines if player's can activate me or not.
var can_be_shown : bool = true

#Listen for when interacts are possible.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self, "_new_interactor")
	
	#Hide InteractsMenu if chatting.
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_STARTED, self, "_set_menu_showable", [false])
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_FINISHED, self, "_set_menu_showable", [true])

#Called from a signal. One of the buttons corresponding to the interactables has been pressed.
func _button_pressed(interactable : Node) -> void :
	#Interact with desired interactable
	interactor_component.player_requested_interact(interactable)

#Remove all buttons and separators for Interactables.
func _clear_button_parent() -> void :
	#Disconnect all signals that are connected.
	for interactable in interactables :
		interactable.disconnect("display_info_changed", self, "_interactable_display_info_changed")
		interactable.disconnect("title_changed", self, "_interactable_title_changed")
	
	for child in button_parent.get_children() :
		child.queue_free()
	
	interactables.clear()

#Add a button to the InteractsMenu.
func _create_button(interact_name : String, info : String, interactable : Interactable) -> Button :
	#Create a button.
	var new_button : Button = Button.new()
	new_button.name = interact_name
	new_button.text = interact_name
	new_button.focus_mode = new_button.FOCUS_ALL
	button_parent.call_deferred("add_child", new_button)
	
	#Grab focus if we are the first button to be created.
	if interactables.empty() :
		new_button.call_deferred("grab_focus")
	
	#Listen for the button to be interacted with.
	new_button.connect("pressed", self, "_button_pressed", [interactable])
	new_button.connect("mouse_entered", self, "_display_button_info", [info])
	new_button.connect("focus_entered", self, "_display_button_info", [info])
	
	return new_button

#Called from a signal. Shows the info of the interactable.
func _display_button_info(button_info : String) -> void :
	description.text = button_info

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
	if interactables.has(interactable_node) :
			Log.warning(self, "_interactable_entered", "%s is already in the Interacts Menu." % interactable_node.get_path())
			return
	
	var button : Button = _create_button(interactable_node.get_title(), interactable_node.get_info(), interactable_node)
	interactables.append(interactable_node)
	
	#Listen for when Interactable attributes have been changed.
	interactable_node.connect("display_info_changed", self, "_interactable_display_info_changed", [button])
	interactable_node.connect("title_changed", self, "_interactable_title_changed", [button])

#Called from a signal. Remove the button corresponding to the interactable from the button list.
func _interactable_left(interactable_node : Interactable) -> void :
	#Exit if interactables does not have the interactable_node
	if not interactables.has(interactable_node) :
		Log.error(self, "_interactable_left", "%s not found in interactable list." % str(interactable_node.get_path()))
		return
	
	#Move focus to another button if there is one.
	var button : Button
	var position_in_array : int = interactables.find(interactable_node)
	button = button_parent.get_child(position_in_array)
	
	#Move focus to the correct node.
	if button.has_focus()  :
		if button_parent.get_child(0).has_focus() == false :
			button_parent.get_child(0).grab_focus()
	
	#Stop listening to the Interactables signals.
	interactable_node.disconnect("display_info_changed", self, "_interactable_display_info_changed")
	interactable_node.disconnect("title_changed", self, "_interactable_title_changed")
	
	#Remove the button from the scene tree.
	button.queue_free()
	interactables.remove(position_in_array)
	
	#Clear the text description if there are no more interactables.
	if interactables.empty() :
		description.text = ""

func _interactable_title_changed(new_title : String, button : Button) -> void :
	button.text = new_title

#Called from a signal. Disconnect the old interactor and connect the new one.
func _new_interactor(new_interactor : InteractorComponent) -> void :
	if interactor_component != null :
		interactor_component.lost_focus()
		interactor_component.disconnect(interactor_component.INTERACTABLE_ENTERED_AREA_REACH, self, "_interactable_entered")
		interactor_component.disconnect(interactor_component.INTERACTABLE_LEFT_AREA_REACH, self, "_interactable_left")
		
		#Clear whatever Interactables are present from the old Interactor.
		_clear_button_parent()
		
	new_interactor.connect(new_interactor.INTERACTABLE_ENTERED_AREA_REACH, self, "_interactable_entered")
	new_interactor.connect(new_interactor.INTERACTABLE_LEFT_AREA_REACH, self, "_interactable_left")
	interactor_component = new_interactor
	
	#Remove the text that may be present from the previous Interactor.
	description.text = ""
	
	#Add the new Interactables to the scene tree.
	for interactable in new_interactor.get_interactables() :
		_interactable_entered(interactable)

#Determines if I can become visible or not.
func _set_menu_showable(is_showable : bool) -> void :
	can_be_shown = is_showable
	
	if can_be_shown :
		set_process_input(true)
	else :
		set_process_input(false)
		hide()
