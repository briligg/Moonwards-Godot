extends Control

var texture setget set_texture
var text setget set_text

signal next_pressed
signal prev_pressed

func _on_next_pressed():
	emit_signal("next_pressed")

func _on_prev_pressed():
	emit_signal("prev_pressed")

func set_texture(tex: Texture):
	$ColorRect/TextureRect.set_texture(tex)
	
func set_text(new_text: String):
	$TextContainer/RichTextLabel.set_text(new_text)
