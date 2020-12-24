extends CanvasLayer

func _ready() -> void  :
	$CenterNotice/Button.connect("pressed", self, "_pressed")

func _pressed() -> void :
	self.queue_free()

func set_text(new_text : String) -> void :
	$CenterNotice/Text.text = new_text
