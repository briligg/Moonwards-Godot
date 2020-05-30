extends PanelContainer
"""
	Chat Scene Script
	
	We are part of the group named Chat.
"""

signal chat_line_entered(message)

onready var _chat_display_node: RichTextLabel = $"V/Tabs/Public"
onready var _chat_input_node: LineEdit = $"V/ChatInput"
onready var _help_node : RichTextLabel = $"V/HelpPage"
onready var _tabs_node: TabContainer = $"V/Tabs"
onready var _previous_display : RichTextLabel = _help_node

#Determines what node richtextlabel has focus.
onready var _current_display : RichTextLabel = _chat_display_node

#How large I was before getting minimized.
#Goes through anchor points in clockwise rotation starting from top.
onready var _panel_anchors : Array = [anchor_top,anchor_right,anchor_bottom,anchor_left]

#Where the chat box is when fully open.
const CHAT_RESIZE_TOP = 0.002
const CHAT_RESIZE_BOTTOM = 0.90
const CHAT_RESIZE_RIGHT = 0.999
const CHAT_RESIZE_LEFT = 0.1

#Determines how far the message can be heard.
enum strength {
	NORMAL = 0,
	SHOUT = 1,
	WHISPER = 2,
	PINNED = 3
}

#How much leeway to give mouse resizing.
const MOUSE_RESIZE_LEEWAY : int = 10

var _active: bool = false
var _chat_is_raised : bool = false

#True when chat window is active, false when chat window is minimized.
var _chat_window_present : bool = true

#Mouse resize variables.
var is_processing_drag : bool = false #Start handling the mouse resize.
var lock_x_drag : bool = false #Prevent resizing X axis
var lock_y_drag : bool = false #Prevent resizing Y axis


func _change_display_node(new_display_node : RichTextLabel) -> void :
	assert(new_display_node!=null)
	
	_previous_display = _current_display
	_current_display = new_display_node

#Check for mouse wanting to resize Chat.
#warning-ignore:unused_argument
func _process(delta : float) -> void :
	var mouse_pos : Vector2 = get_global_mouse_position()
	
	if is_processing_drag :
		_process_drag(mouse_pos)
		return
	
	#Check if the mouse is near the corners.
	if(mouse_pos.x >= (rect_size.x + rect_position.x) - MOUSE_RESIZE_LEEWAY &&
			mouse_pos.x <= (rect_size.x + rect_position.x) + MOUSE_RESIZE_LEEWAY) :
		if(mouse_pos.y >= rect_position.y - MOUSE_RESIZE_LEEWAY &&
				mouse_pos.y <= rect_position.y + MOUSE_RESIZE_LEEWAY) :
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			lock_x_drag = false
			lock_y_drag = false
		else :
			Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
			lock_y_drag = true
			lock_x_drag = false
		
		#Start handling the player resizing the window.
		if Input.is_mouse_button_pressed(BUTTON_MASK_LEFT) :
			is_processing_drag = true
	
	elif(mouse_pos.y >= rect_position.y - MOUSE_RESIZE_LEEWAY &&
			mouse_pos.y <= rect_position.y + MOUSE_RESIZE_LEEWAY) :
		Input.set_default_cursor_shape(Input.CURSOR_VSIZE)
		lock_x_drag = true
		lock_y_drag = false
		
		#Start handling the player resizing the window.
		if Input.is_mouse_button_pressed(BUTTON_MASK_LEFT) :
			is_processing_drag = true
	else :
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		lock_x_drag = false
		lock_y_drag = false

func _process_drag(mouse_pos : Vector2) -> void :
	#Stop resizing if the mouse is no longer held down.
	if Input.is_mouse_button_pressed(BUTTON_MASK_LEFT) == false :
		is_processing_drag = false
		return
	
	#Turn mouse pos to valid anchor points.
	var window_size : Vector2 = OS.get_window_size()
	mouse_pos.x = (mouse_pos.x / window_size.x)
	mouse_pos.y = (mouse_pos.y / window_size.y)
	
	#Prevent axis from being resized when they are not supposed to.
	#Resize the axis we want to resize.
	if lock_x_drag == false :
		anchor_right = clamp(mouse_pos.x, CHAT_RESIZE_LEFT, CHAT_RESIZE_RIGHT)
	if lock_y_drag == false :
		anchor_top = clamp(mouse_pos.y, CHAT_RESIZE_TOP, CHAT_RESIZE_BOTTOM)

#Handle input that controls Chat.
func _unhandled_input(event: InputEvent) -> void:
	if not visible or _active :
		return
	
	if event is InputEventKey:
		if event.pressed == false :
			return
		
		if event.scancode == KEY_ENTER:
			#Show the correct menu.
			_help_node.hide()
			_tabs_node.show()
			_change_display_node(_tabs_node.get_child(_tabs_node.current_tab))
			
			_chat_input_node.grab_focus()
			_chat_input_node.editable = true
			_active = true
		
		elif event.scancode == KEY_H :
			#Show the help page if it is not already open.
			if $V/HelpPage.visible == false :
				_help_node.show()
				_tabs_node.hide()
				_change_display_node(_help_node)
			
			#Stop showing the help page if it is already open.
			else :
				_help_node.hide()
				_tabs_node.show()
				_change_display_node(_previous_display)
		
		elif event.scancode == KEY_V :
			if _chat_is_raised : #Lower the chat.
				lower_chat()
			else :
				raise_chat()
		
		#Now determine if the player is trying to scroll the chat window.
		elif event.scancode == KEY_T :
			#Scroll upwards.
			var _v_scroll_bar : VScrollBar = _current_display.get_v_scroll()
			_v_scroll_bar.value = _v_scroll_bar.value - _v_scroll_bar.page
		
		elif event.scancode == KEY_G :
			#Scroll downwards.
			var _v_scroll_bar : VScrollBar = _current_display.get_v_scroll()
			_v_scroll_bar.value = _v_scroll_bar.value + _v_scroll_bar.page
		
		elif event.scancode == KEY_C :
			#Increase Chat horizontal size.
			anchor_right = min(anchor_right + 0.05, CHAT_RESIZE_RIGHT)
		
		elif event.scancode == KEY_X :
			#Decrease chat horizontal size.
			anchor_right = max(anchor_right - 0.05, CHAT_RESIZE_LEFT)
		
		elif event.scancode == KEY_1 :
			_current_display.show()
			#Increase chat vertical size.
			anchor_top = max(anchor_top - 0.05, CHAT_RESIZE_TOP)
		
		elif event.scancode == KEY_Q :
			#Decrease chat vertical size.
			#I have to hide Chat if we are trying to scale down 
			#past the allowed rect size.
			anchor_top = min(anchor_top + 0.05, CHAT_RESIZE_BOTTOM)
		
		elif event.scancode == KEY_2 :
			_toggle_chat_window()

func _on_LineEdit_text_entered(new_text: String) -> void:
	_chat_input_node.clear()
	_chat_input_node.release_focus()
	_chat_input_node.editable = false
	
	set_deferred("_active", false)

	#If the first character in the new text is an exclamation mark(!),
	#shout the message and remove the asterisk.
	var message_strength : int = strength.NORMAL
	if new_text.begins_with("!") :
		message_strength = strength.SHOUT
		new_text.erase(0,1)
	
	#Three dashes(---) means whisper.
	elif new_text.begins_with("---") :
		message_strength = strength.WHISPER
		new_text.erase(0,3)
	
	#Three asterisks means the message is pinned.
	elif new_text.begins_with("***") :
		message_strength = strength.PINNED
		new_text.erase(0,3)
	
	#Remove unneeded characters from beginning and end of text.
	new_text = new_text.dedent()
	
	if new_text == "" :
		return
	
	emit_signal("chat_line_entered", new_text, message_strength)

#This changes the chat between window active and window minimized.
func _toggle_chat_window() -> void :
	#Chat window is visible, minimize it.
	if _chat_window_present :
		_chat_window_present = false
		
		_panel_anchors[0] = anchor_top
		_panel_anchors[1] = anchor_right
		_panel_anchors[2] = anchor_bottom
		_panel_anchors[3] = anchor_left
		
		#Make Chat smaller.
		_chat_display_node.hide()
		_chat_input_node.hide()
		anchor_top = 0
		anchor_right = 0
		anchor_bottom = 0
		anchor_left = 0
		
		#Stop processing mouse resizing.
		set_process(false)
		is_processing_drag = false
	
	#Chat window is currently minimized, make it have a presence again.
	else :
		_chat_window_present = true
		
		#Make Chat have a  presence again.
		anchor_top = _panel_anchors[0]
		anchor_right = _panel_anchors[1]
		anchor_bottom = _panel_anchors[2]
		anchor_left = _panel_anchors[3]
		_chat_display_node.show()
		_chat_input_node.show()
		
		set_process(true)
	
	#If something has made me invisible before this method was called, make
	#myself visible again.
	visible = true

#Add a message to the chat history.
func add_message(new_text: String) -> void:
	_chat_display_node.add_message(new_text)

#Cause the chat to fade into being invisible.
#Meant to be called from somewhere else. Usually from a group call.
func hide_chat() -> void :
	#Don't play the fading animation if I am already invisible.
	if visible == false : return
	
	#Make Chat invisible. 
	$ChatAnims.play("Visibility")

#Make the chat as small as possible.
func lower_chat() -> void :
	_tabs_node.hide()
	_current_display.hide()
	anchor_top = 1
	_chat_is_raised = false

#Bring the chat up to the maximum height.
func raise_chat() -> void :
	_tabs_node.show()
	_current_display.show()
	anchor_top = CHAT_RESIZE_TOP
	_chat_is_raised = true

#Show the chat to the player.
#Meant to be called from somewhere else. Usually from a group call.
func show_chat() -> void :
	#Don't do anything if Chat is already displayed.
	if visible : return
	
	#Make chat visible.
	$ChatAnims.play_backwards("Visibility")

func _link_clicked(meta):
	OS.shell_open(meta)

#Player clicked on a different tab. Go ahead and update the current tab.
func _on_Tabs_tab_changed(tab : int):
	_change_display_node(_tabs_node.get_child(tab))
