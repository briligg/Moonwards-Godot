extends Control

var texture setget set_texture
var string setget set_string

signal next_pressed
signal prev_pressed

func _on_next_pressed():
	emit_signal("next_pressed")

func _on_prev_pressed():
	emit_signal("prev_pressed")

func set_texture(tex: Texture):
	$TextureRect.set_texture(tex)
	
func set_string(text: String):
	$TextContainer/RichTextLabel.set_text(text)
