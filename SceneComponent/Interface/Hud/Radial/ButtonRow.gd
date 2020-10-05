extends HBoxContainer

#Emitted when a button has been pressed.
signal button_selected()

export var color : Color = Color(0,1,0,1)
var custom_style : StyleBoxFlat = StyleBoxFlat.new()

var past_button : Button = null
var current_button : Button = null


#One of the buttons on the row has been toggled.
func _button_toggled(button : Button) -> void :
	#Reset the past buttons color.
	past_button = current_button
	if not past_button == null :
		past_button.add_stylebox_override("focus", null)
		past_button.add_stylebox_override("normal", null)
	
	#Set the new buttons color
	current_button = button
	current_button.add_stylebox_override("focus", custom_style)
	current_button.add_stylebox_override("normal", custom_style)
	
	emit_signal("button_selected")

func _ready() -> void :
	custom_style.bg_color = color
	_recurse_children(self)

func _recurse_children(node : Node) -> void :
	if node is Button :
		node.connect("pressed", self, "_button_toggled", [node])
	
	for child in node.get_children() :
		_recurse_children(child)

#Make all buttons go to their normal setup.
func deselect_buttons() -> void :
	if not past_button == null :
		past_button.add_stylebox_override("focus", null)
		past_button.add_stylebox_override("normal", null)
	
	if not current_button == null :
		current_button.add_stylebox_override("focus", null)
		current_button.add_stylebox_override("normal", null)
	
	current_button = null
	past_button = null
