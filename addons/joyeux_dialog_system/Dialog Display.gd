extends Control
onready var Controls = $HBC/VBC/TextContainer/HBoxContainer/VBoxContainer/Controls
onready var CharName = $HBC/VBC/TextContainer/HBoxContainer/VBoxContainer/CharName
onready var Text = $HBC/VBC/TextContainer/HBoxContainer/VBoxContainer/CurrentText


func hide_controls():
	Controls.hide()

func set_name(charname : String):
	CharName.text = charname

func set_text(text : String):
	Text.text = text
