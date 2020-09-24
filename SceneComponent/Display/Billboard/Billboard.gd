"""

	Use this class for showing-up independent screens within the game.

"""

tool
extends Spatial

# Member variables
onready var screen = $Screen
onready var slide_control = $Screen.content_instance

export(Array, Texture) var texture_slides
export(Array, String) var text_slides


var slide_index: int = 0
var slide_size: int = 0

#Listen to the buttons and verify that slides are setup correctly.
func _ready() -> void :
	slide_control.connect("next_pressed", self, "_on_next_pressed")
	slide_control.connect("prev_pressed", self, "_on_prev_pressed")
	
	if texture_slides.size() != text_slides.size():
		Log.error(self, "_ready", "Texture array size is not the same as text array size.")
		assert(false)
	else:
		slide_size = texture_slides.size()
	
	#At start of scene, make SlidePresentation display first slide.
	if not text_slides.empty() :
		slide_control.set_text(text_slides[0])
		slide_control.set_texture(texture_slides[0])

#Go to next slide. Cycle to beginning if already at last slide.
func _on_next_pressed() -> void :
	#If we have more slides to go to, go to the next one.
	if slide_size > slide_index + 1:
		slide_index += 1
	
	#We have reached the end of the slides. Cycle back to the beginning.
	else:
		slide_index = 0
	slide_control.set_texture(texture_slides[slide_index])
	slide_control.set_text(text_slides[slide_index])

#Go to previous slide. Cycle to the last slide if at the first slide already.
func _on_prev_pressed() -> void :
	#Move to the previous slide if there are still previous slides remaining.
	if slide_index > 0:
		slide_index -= 1
	
	#We are at the first slide, move to the last slide of the list.
	else:
		slide_index = slide_size - 1
	slide_control.set_texture(texture_slides[slide_index])
	slide_control.set_text(text_slides[slide_index])

