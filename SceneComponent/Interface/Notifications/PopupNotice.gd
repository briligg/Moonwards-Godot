extends CanvasLayer

func _ready() -> void  :
	$CenterNotice/Button.connect("pressed", self, "_pressed")
	$CenterNotice/Text.connect("meta_clicked", self, "_link_clicked")

func _pressed() -> void :
	self.queue_free()

func set_text(new_text : String) -> void :
	new_text = Helpers.setup_text_with_links(new_text)
	$CenterNotice/Text.bbcode_text = new_text

func _link_clicked(link_text : String) -> void :
	OS.shell_open(link_text)
