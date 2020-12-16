extends HBoxContainer


func _ready() -> void :
	$Twitter.connect("pressed", self, "_link_pressed", ["https://twitter.com/moonwards1"])
	$Reddit.connect("pressed", self, "_link_pressed", ["https://www.reddit.com/r/Moonwards/"])
	$Discord.connect("pressed", self, "_link_pressed", ["https://discord.gg/QHr62v8"])

func _link_pressed(link : String) -> void :
	OS.shell_open(link)
