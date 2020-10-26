extends Reference
class_name NetworkSignals

### Until we or godot implements proper class_name handling
const name = "Network"

### LOBBY MANAGEMENT 

# Fired when a request is received for a game to be started. 
const GAME_SERVER_REQUESTED: String = "game_server_requested"

signal game_server_requested(is_host_player)

# Fired when the process is initialized as a game server & is ready to receive connections
const GAME_SERVER_READY: String = "game_server_ready"

signal game_server_ready

# Fired when the process is requested to be a client
const GAME_CLIENT_REQUESTED: String = "game_client_requested"

signal game_client_requested(ip, port)

# Fired when the process is initiated as a client, is connected & is ready
const GAME_CLIENT_READY: String = "game_client_ready"

signal game_client_ready

### LOADING & DATA MANAGEMENT


# Fired when a connected player client has finished loading.
# param `peer_id`: The player's peer_id
const CLIENT_LOAD_FINISHED: String = "client_load_finished"

signal client_load_finished(peer_id)

const CLIENT_NAME_CHANGED: String = "client_name_changed"

signal client_name_changed(name)

const CLIENT_COLOR_CHANGED: String = "client_color_changed"

signal client_color_changed(colors)

const NEW_PLAYER_POST_LOAD: String = "new_player_post_load"

signal new_player_post_load(peer_id)


### IN GAME EVENTS

# Fired when a chat message is received from the server
# `sender_id: int` the peer_id of the sender
# `message: String` the message
const CHAT_MESSAGE_RECEIVED: String = "chat_message_received"

signal chat_message_received(sender_id, message)
