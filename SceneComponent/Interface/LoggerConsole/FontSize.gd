extends LineEdit


var par_font : Font

func _ready() -> void :
	call_deferred("_ready_deferred")
	
	.connect("text_entered", self, "_update_font")

func _ready_deferred() -> void :
	par_font = get_parent().get_font("default_font")
	text = str(par_font.get("size"))

func _update_font(new_text : String) -> void :
	if new_text.is_valid_integer() :
		par_font.set("size", int(new_text))
	else :
		text = "int only. " + str(par_font.get("size"))
