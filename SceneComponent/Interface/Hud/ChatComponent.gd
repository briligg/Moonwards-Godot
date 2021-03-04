extends MwSpatial
onready var chatbox = $Chat

#How long to wait before removing a message.
export var message_ttl : int = 7200

#History of chat messages.
var history_timers : Array = []
var history : PoolStringArray = PoolStringArray()

func _init():
	pass

func _ready() -> void:
	chatbox.connect("chat_line_entered", self, "_chat_line_entered")
	
	#Give client chat the message history.
	Signals.Network.connect(NetworkSignals.NEW_PLAYER_POST_LOAD, self, "sync_new_chat")

func _chat_line_entered(message: String, _strength: int) -> void:
	rpc_id(1, "_send_chat_message", message)

#`MASTER`
# Runs on the server
master func _send_chat_message(message: String) -> void:
	# process & beam it back to all clients
	var e = Network.get_sender_entity()
	var m = "%s: %s" %[e.entity_name, message]
	Log.trace(self, "", "Sending chat message: %s" % m)
	crpc("_receive_chat_message", m)
	
	#Add the message to the history. Start a timer to remove the message when it becomes too old.
	history.append(m)
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.wait_time = message_ttl
	timer.start()
	timer.connect("timeout", self, "pop_history", [timer])
	history_timers.append(timer)

func pop_history(timer : Timer) -> void :
	history.remove(0)
	history_timers.remove(0)
	if has_node(timer.get_path()) :
		timer.queue_free()
	else :
		Log.error(self, "pop_history", "%s's should have had the calling timer as a child. This error might cause a memory leak" % get_path())

master func sync_new_chat(chat_id : int) -> void :
	rpc_id(chat_id, "client_chat_sync", history)

puppetsync func client_chat_sync(sync_history : PoolStringArray) -> void :
	for message in sync_history :
		chatbox.add_message(message)

#`PUPPETSYNC`
# Runs on the clients
puppetsync func _receive_chat_message(message: String) -> void:
	Log.trace(self, "", "Received chat message: %s" % message)
	chatbox.add_message(message)
