extends Node
"""
	Boot Scene Script
	Initializes headless server if required
"""

func _ready() -> void:
#	if OS.has_feature("Server"):
#		_ready_headless()
#	else:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var arguments = {}
	for argument in OS.get_cmdline_args():
	# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	if arguments.has("server"):
		if arguments.server == "true":
			_ready_headless()
	else:
		MainMenu.show()	


func _ready_headless() -> void:
	Log.hint(self, "_ready_headless", "Initializing Headless Server")
	print("Starting server 1/4: Trying to load the world")
	
	var player_data : Dictionary = {
		name = "Server bot",
		options = Options.player_data_set_pattern("server_bot")
	}
	Lobby.connect_to_server(player_data, true)
