extends Control

enum SLOTS{
	PANTS,
	SHIRT,
	SKIN,
	HAIR,
	SHOES
}

var pants_color : = Color(0,0,1)
var shirt_color : = Color(0.1,0.4,1)
var skin_color : = Color(0.59,0.4,0)
var hair_color : = Color(0.1,0.1,0.1)
var shoes_color : = Color(1,1,1)

var current_slot : int = SLOTS.PANTS

# Needs to use the paths before it's ready, so it will crash using onready
var username_edit : String = "ModelDisplay/UsernameEdit"
var gender_edit : String = "VBoxContainer/Gender"
var avatar_preview : String = "ModelDisplay/ViewportContainer/Viewport/AvatarPreview"
var hue_picker : String = "VBoxContainer/HuePicker"
var button_containter : String = "ModelDisplay/ViewportContainer"

var username : String = "default username"
const GENDER_MALE : int = 1
const GENDER_FEMALE : int = 0
var gender : int = GENDER_MALE


func _ready() -> void:
	get_node(username_edit).text = username
	switch_slot()
	_on_Gender_item_selected(gender)
	get_node(gender_edit).selected = gender
	get_node(button_containter).get_node("Viewport").size = get_node(button_containter).rect_size

func switch_slot() -> void:
	if current_slot == SLOTS.PANTS:
		get_node(hue_picker).color = pants_color
	elif current_slot == SLOTS.SHIRT:
		get_node(hue_picker).color = shirt_color
	elif current_slot == SLOTS.SKIN:
		get_node(hue_picker).color = skin_color
	elif current_slot == SLOTS.HAIR:
		get_node(hue_picker).color = hair_color
	elif current_slot == SLOTS.SHOES:
		get_node(hue_picker).color = shoes_color
	get_node(avatar_preview).set_colors(pants_color, shirt_color, skin_color, hair_color, shoes_color)

func _on_HuePicker_Hue_Selected(color : Color) -> void:
	if current_slot == SLOTS.PANTS:
		 pants_color = color
	elif current_slot == SLOTS.SHIRT:
		 shirt_color = color
	elif current_slot == SLOTS.SKIN:
		 skin_color = color
	elif current_slot == SLOTS.HAIR:
		 hair_color = color
	elif current_slot == SLOTS.SHOES:
		 shoes_color = color
	get_node(avatar_preview).set_colors( pants_color,  shirt_color,  skin_color,  hair_color,  shoes_color)

func _on_CfgPlayer_pressed() -> void:
	$WindowDialog.popup_centered()

func _on_SaveButton_pressed() -> void:
	#Currently just log what the player is doing.
	Log.trace(self, "_on_SaveButton_pressed", "Save button pressed by player.")
	
	#Emit signals to let the Network know we changed things.
	Signals.Network.emit_signal(Signals.Network.CLIENT_NAME_CHANGED, username)
	
	#Emit the shirt color signals.
#	for clothing_color in [pants_color, shirt_color, hair_color, skin_color, shoes_color] :
#		Signals.Network.emit_signal(Signals.Network.CLIENT_COLOR_CHANGED, clothing_color)
	Signals.Network.emit_signal(Signals.Network.CLIENT_COLOR_CHANGED, [pants_color, shirt_color, hair_color, skin_color, shoes_color])

func _on_SlotOption_item_selected(ID : int) -> void:
	current_slot = ID
	switch_slot()

func _on_Gender_item_selected(ID : int) -> void:
	gender = ID
	get_node(avatar_preview).set_gender(gender)
	if ID == 0:
		get_node(button_containter).get_node("Female").show()
		get_node(button_containter).get_node("Male").hide()
	else:
		get_node(button_containter).get_node("Female").hide()
		get_node(button_containter).get_node("Male").show()

func _on_UsernameTextEdit_text_changed(new_text : String) -> void:
	username = new_text
	Log.trace(self, "_on_UsernameTextEdit_text_changed", "Change player's name.'")
	
