extends HBoxContainer


onready var START_GAME : Button = get_node("VBoxContainer/Destination") setget _do_not_set_buttons
onready var SETTINGS : Button = get_node("VBoxContainer/Avatar") setget _do_not_set_buttons
onready var OTHER : Button = get_node("VBoxContainer/Controls") setget _do_not_set_buttons
onready var PANEL : PanelContainer = get_node("Panel") setget _do_not_set_buttons

#Determines what button to draw from.
onready var current_button : Button = START_GAME

#These are the current surges.
var surges : Array = []
#What gets shown when a surge reaches the panel.
var surge_transfers : Array = []

#How long surge transfers last in seconds.
const TRANSFER_DURATION : float = 0.18
#How fast the surges travel.
const SURGE_SPEED : float = 248.0

#Add a surge to be drawn from the button to the panel.
func _create_surge() -> void :
	var surge : Array = []
	var surge_position : Vector2 = Vector2()
	surge_position.x = current_button.rect_position.x + current_button.rect_size.x
	surge_position.y = current_button.rect_position.y + (current_button.rect_size.y * 0.5)
	surge.append(surge_position)
	
	#Append the new surge to the list of surges.
	surges.append(surge)

func _draw() -> void :
	#Draw a line from the currently highlighted button to the panel.
	var draw_from : Vector2 = Vector2()
	draw_from.x = current_button.rect_position.x + current_button.rect_size.x
	draw_from.y = current_button.rect_position.y + (current_button.rect_size.y * 0.5)
	var draw_to : Vector2 = Vector2()
	draw_to.x = PANEL.rect_position.x
	draw_to.y = draw_from.y
	draw_line(draw_from, draw_to, Color(1,1,1,1), 3.0)
	
	#Animate the surges.
	for surge in surges :
		var rect1 : Rect2 = Rect2(surge[0].x, surge[0].y - 6, 4, 12)
		var rect2 : Rect2 = Rect2(surge[0].x - 6, surge[0].y - 5, 4, 10)
		var rect3 : Rect2 = Rect2(surge[0].x + 6, surge[0].y - 4, 3, 8)
		var rect4 : Rect2 = Rect2(surge[0].x - 11, surge[0].y - 4, 3, 8)
		draw_rect(rect1, Color(1,1,1,1))
		draw_rect(rect2, Color(1,1,1,1))
		draw_rect(rect3, Color(1,1,1,1))
		draw_rect(rect4, Color(1,1,1,1))
	
	#Animate the surge transfers.
	for transfer in surge_transfers :
		var middle_rect : Rect2 = Rect2()
		if transfer[1] >= TRANSFER_DURATION - (TRANSFER_DURATION * 0.25) :
			middle_rect = Rect2(transfer[0].x - 3, transfer[0].y - 5, 6, 10)
		elif transfer[1] >= TRANSFER_DURATION - (TRANSFER_DURATION * 0.50) :
			middle_rect = Rect2(transfer[0].x - 2, transfer[0].y - 8, 4, 16)
		elif transfer[1] >= TRANSFER_DURATION - (TRANSFER_DURATION * 0.75) :
			middle_rect = Rect2(transfer[0].x - 2, transfer[0].y - 9, 4, 18)
		else :
			middle_rect = Rect2(transfer[0].x - 2, transfer[0].y - 10, 4, 20)
		draw_rect(middle_rect, Color(1,1,1,1))

#Draw each frame to keep up to date with resolution changes.
#warning-ignore:unused_argument
func _process(delta : float) -> void :
	update()
	
	#Move the surges.
	var remove_surges : Array = []
	for surge in surges :
		surge[0].x += SURGE_SPEED * delta
		
		#This is for freeing the surge if it has reached the panel.
		if surge[0].x >= PANEL.rect_position.x :
			remove_surges.append(surges.find(surge))
	
	#Remove the surges that are past the Panel.
	remove_surges.invert()
	for pos in remove_surges :
		#Add a surge transfer at the location of the free'd surge.
		var transfer_position : Vector2 = Vector2(PANEL.rect_position.x, surges[pos][0].y)
		surge_transfers.append([transfer_position, TRANSFER_DURATION])
		
		#Actually remove the surge
		surges.remove(pos)
	
	#Track the lifetime of the surge transfers. 
	#Remember surge transfers that have lasted past their duration to free later.
	#warning-ignore:return_value_discarded
	remove_surges = []
	for transfer in surge_transfers :
		if transfer[1] <= 0 :
			remove_surges.append(surge_transfers.find(transfer))
		transfer[1] -= delta
	
	#Remove the dead surge transfers
	remove_surges.invert()
	for pos in remove_surges :
		surge_transfers.remove(pos)

func _ready() -> void :
	get_node("VBoxContainer/Destination").grab_focus()

#This forbids the onready buttons from being set since they act as constants.
#warning-ignore:unused_argument
func _do_not_set_buttons(new_value) -> void :
	assert(true == false)

#Called by buttons when they are highlighted.
func _button_highlighted(button_name : String) -> void :
	#If this fails it is because the button's name is not passed correctly.
	assert(has_node("VBoxContainer/" + button_name))
	current_button = get_node("VBoxContainer/" + button_name)
	_create_surge()
