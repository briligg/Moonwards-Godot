extends Container

export var button_radius = 100 #in godot position units
export var radial_width = 50 #in godot position units

#The different reachable submenus for the radial buttons.
onready var actions : VBoxContainer = $ContainerActions
onready var expressions : VBoxContainer = $ContainerExpression

#This is the menu you see when first bringing up RadialMenu.
onready var main : HBoxContainer = $ContainerMain


#Listen for RadialMenu action to be pressed.
func _input(event : InputEvent) -> void :
	if event.is_action_pressed("radial_menu") :
		toggle_visibility()

# Place buttons in the correct location and listen for radial button presses.
func _ready():
	var button : Button
	button = $ContainerMain/MarginContainer/MarginContainer/Button_Actions
	button.connect("pressed", self, "_show_menu", [actions])
	
	button = $ContainerMain/MarginContainer2/MarginContainer/Button_Expressions
	button.connect("pressed", self, "_show_menu", [expressions])
	
	hide()
	place_buttons()
	
	#Tenporary solution. Go through each button in the submenus and hide the menu
	#if they are pressed.
	_recurse_children(actions)
	_recurse_children(expressions)

#Temporary function for hiding the RadialSelector when a sub menu is pressed..
func _recurse_children(node : Node) -> void :
	if node is Button :
		node.connect("pressed", self, "toggle_visibility")
	
	for child in node.get_children() :
		_recurse_children(child)

#This brings up the submenu that is related to the pressed button.
func _show_menu(submenu : Control) -> void :
	submenu.show()
	main.hide()

#Repositions the buttons
func place_buttons():
	var buttons = get_children()

	#Stop before we cause problems when no buttons are available
	if buttons.size() == 0:
		return

	#Amount to change the angle for each button
	var angle_offset = (2*PI)/buttons.size() #in degrees

	var angle = 0 #in radians
	for btn in buttons: 
		#calculate the x and y positions for the button at that angle
		var _x = cos(angle)*button_radius
		var _y = sin(angle)*button_radius

		var circle_pos = Vector2(button_radius, 0).rotated(angle)
		#set button's position
		#>we want to center the element on the circle. 
		#>to do this we need to offset the calculated x and y respectively by half the height and width
		btn.rect_position = circle_pos-(btn.get_size()/2)
		#Note: A bit confused but somehow godot corrects the sign on it's own so that isn't needed.

		#set button's position
		#>we want to center the element on the circle. 
		#>to do this we need to offset the calculated x and y respectively by half the height and width
		#var corner_pos = Vector2(x, -y)-(btn.get_size()/2) #Screen coordinates so calculated y must be negated
		#btn.set_position(corner_pos)

		#Advance to next angle position
		angle += angle_offset

#Toggle radial menu visibility. It sets the menu back to being the inital setup.
func toggle_visibility() -> void :
	visible = !visible
	
	main.show()
	expressions.hide()
	actions.hide()

#utility function for adding buttons and recalculating their positions
#TODO: Should probably just use a signal to run place_button on any tree change
func add_button(btn):
	add_child(btn)
	place_buttons()
