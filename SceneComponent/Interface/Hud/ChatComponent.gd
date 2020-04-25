extends MwSpatial
onready var chatbox = $Chat

func _init():
	pass

func _ready():
	chatbox.connect("chat_line_entered", self, "_chat_line_entered")

func _chat_line_entered(message: String) -> void:
	rpc_id(1, "_send_chat_message", message)

#`MASTER`
# Runs on the server
master func _send_chat_message(message: String) -> void:
	# process & beam it back to all clients
	var e = Network.get_sender_entity()
	var m = "%s: %s" %[e.entity_name, message]
	Log.trace(self, "", "Sending chat message: %s" % m)
	crpc("_receive_chat_message", m)

#`PUPPETSYNC`
# Runs on the clients
puppetsync func _receive_chat_message(message: String) -> void:
	Log.trace(self, "", "Received chat message: %s" % message)
	chatbox.add_message(message)
