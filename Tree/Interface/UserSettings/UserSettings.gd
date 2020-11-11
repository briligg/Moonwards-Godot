extends Control

# skin_color,  hair_color,  shirt_color,  pants_color,  shoes_color)
enum SLOTS{
	SKIN,
	HAIR,
	SHIRT,
	PANTS,
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
var gender_edit : String = "VBoxContainer/Buttons/VBoxContainer/Gender"
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

#Returns the colors in this order skin_color, hair_color, shirt_color, pants_color, shoes_color.
func get_colors() -> Array :
	return [skin_color, hair_color, shirt_color, pants_color, shoes_color]

func set_gender(gender_id : int) -> void :
	_on_Gender_item_selected(gender_id)

#Pass colors in array in this order skin_color, hair_color, shirt_color, pants_color, shoes_color
func set_colors(color_array) -> void :
	skin_color = color_array[0]
	hair_color = color_array[1]
	shirt_color = color_array[2]
	pants_color = color_array[3]
	shoes_color = color_array[4]
	get_node(avatar_preview).set_colors(skin_color,  hair_color,  shirt_color,  pants_color,  shoes_color)
	
	#Update the slot so it points to the correct one.
	switch_slot()

func set_username(new_name : String) -> void :
	username = new_name
	$ModelDisplay/UsernameEdit.text = username

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
	get_node(avatar_preview).set_colors(skin_color, hair_color, shirt_color, pants_color, shoes_color)

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
	get_node(avatar_preview).set_colors(skin_color,  hair_color,  shirt_color,  pants_color,  shoes_color)

func _on_CfgPlayer_pressed() -> void:
	$WindowDialog.popup_centered()

func _on_SaveButton_pressed() -> void:
	#Currently just log what the player is doing.
	Log.trace(self, "_on_SaveButton_pressed", "Save button pressed by player.")
	
	#Emit signals to let the Network know we changed things.
	Signals.Network.emit_signal(Signals.Network.CLIENT_NAME_CHANGED, username)
	
	#Let Networking know we changed genders.
	Signals.Network.emit_signal(Signals.Network.CLIENT_GENDER_CHANGED, gender)
	
	#Emit the shirt color signals.
	Signals.Network.emit_signal(Signals.Network.CLIENT_COLOR_CHANGED, [skin_color, hair_color, shirt_color, pants_color, shoes_color])
	
	#Save the user settings for later.
	get_parent().save()

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
	
