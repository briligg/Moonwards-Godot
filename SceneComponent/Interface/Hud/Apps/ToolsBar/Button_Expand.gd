extends Button


#Hack to work around a bug where buttons are being pressed twice.
var hack_two_press_bug : bool = true

var is_collapsed : bool = false

func _pressed() -> void :
	if hack_two_press_bug :
		hack_two_press_bug = false
		return
	
	#Make it so I rotate perfectly.
	var texture : TextureRect = get_node("../TextureRect")
	texture.rect_pivot_offset = texture.rect_size * 0.5
	
	var dynamic_anim : AnimationPlayer
	dynamic_anim = get_node("../../../../../Anim")
	
	#Play backwards if need be.
	if is_collapsed :
		dynamic_anim.play("show")
	else :
		dynamic_anim.play("hide")
	
	is_collapsed = !is_collapsed
	hack_two_press_bug = true

func _ready() -> void :
	connect("pressed", self, "_pressed")
