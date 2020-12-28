extends HBoxContainer


func _ready() -> void :
	$Source.connect("pressed", self, "_link_pressed", ["https://github.com/moonwards1/Moonwards-Virtual-Moon"])
	$Twitter.connect("pressed", self, "_link_pressed", ["https://twitter.com/moonwards1"])
	$Reddit.connect("pressed", self, "_link_pressed", ["https://www.reddit.com/r/Moonwards/"])
	$Discord.connect("pressed", self, "_link_pressed", ["https://discord.gg/QHr62v8"])
	$Label_Version.text = "Game Version %s     Sites:  " %WorldConstants.VERSION
	
func _link_pressed(link : String) -> void :
	OS.shell_open(link)
