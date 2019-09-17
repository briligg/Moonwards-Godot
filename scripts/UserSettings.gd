extends Control

enum SLOTS{
	PANTS,
	SHIRT,
	SKIN,
	HAIR,
	SHOES
}

var current_slot : int = SLOTS.PANTS

# Needs to use the paths before it's ready, so it will crash using onready
var text_edit1 : String = "VBoxContainer/UsernameContainer/UsernameTextEdit"
var text_edit2 : String = "VBoxContainer2/UsernameTextEdit2"
var gender_edit : String = "VBoxContainer/Gender"
var avatar_preview : String = "VBoxContainer2/ViewportContainer/Viewport/AvatarPreview"
var hue_picker : String = "VBoxContainer/HuePicker"
var button_containter : String = "VBoxContainer2/ViewportContainer"


func _ready() -> void:
	
	get_node(text_edit1).text = options.username
	get_node(text_edit2).text = options.username
	switch_slot()
	_on_Gender_item_selected(options.gender)
	get_node(gender_edit).selected = int(options.gender)
	get_node(button_containter).get_node("Viewport").size = get_node(button_containter).rect_size

func switch_slot() -> void:
	if current_slot == SLOTS.PANTS:
		get_node(hue_picker).color = options.pants_color
	elif current_slot == SLOTS.SHIRT:
		get_node(hue_picker).color = options.shirt_color
	elif current_slot == SLOTS.SKIN:
		get_node(hue_picker).color = options.skin_color
	elif current_slot == SLOTS.HAIR:
		get_node(hue_picker).color = options.hair_color
	elif current_slot == SLOTS.SHOES:
		get_node(hue_picker).color = options.shoes_color
	get_node(avatar_preview).SetColors(options.pants_color, options.shirt_color, options.skin_color, options.hair_color, options.shoes_color)

func _on_HuePicker_Hue_Selected(color : Color) -> void:
	if current_slot == SLOTS.PANTS:
		options.pants_color = color
	elif current_slot == SLOTS.SHIRT:
		options.shirt_color = color
	elif current_slot == SLOTS.SKIN:
		options.skin_color = color
	elif current_slot == SLOTS.HAIR:
		options.hair_color = color
	elif current_slot == SLOTS.SHOES:
		options.shoes_color = color
	get_node(avatar_preview).SetColors(options.pants_color, options.shirt_color, options.skin_color, options.hair_color, options.shoes_color)

func _on_CfgPlayer_pressed() -> void:
	$WindowDialog.popup_centered()

func _on_SaveButton_pressed() -> void:
	options.SaveUserSettings()
	UIManager.back()

func _on_SlotOption_item_selected(ID : int) -> void:
	get_node(avatar_preview).clean_selected()
	get_node(avatar_preview).set_selected(ID)
	current_slot = ID
	switch_slot()


func _on_Gender_item_selected(ID : int) -> void:
	options.gender = ID
	get_node(avatar_preview).SetGender(options.gender)
	if ID == 0:
		get_node(button_containter).get_node("Female").show()
		get_node(button_containter).get_node("Male").hide()
	else:
		get_node(button_containter).get_node("Female").hide()
		get_node(button_containter).get_node("Male").show()

func _on_UsernameTextEdit_text_changed(new_text : String) -> void:
	options.username = new_text
	get_node(text_edit2).text = new_text

func _on_UsernameTextEdit2_text_changed(new_text : String) -> void:
	options.username = new_text
	get_node(text_edit1).text = new_text
