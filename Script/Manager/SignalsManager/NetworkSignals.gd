extends Reference
class_name NetworkSignals

# Fired when a request is received for a game to be started. 
const GAME_SERVER_REQUESTED: String = "game_server_requested"

# Fired when the process is initialized as a game server & is ready to receive connections
const GAME_SERVER_READY: String = "game_server_ready"

# Fired when the process is requested to be a client
const GAME_CLIENT_REQUESTED: String = "game_client_requested"

# Fired when the process is initiated as a client, is connected & is ready
const GAME_CLIENT_READY: String = "game_client_ready"

#warning-ignore:unused_signal
signal game_server_requested
#warning-ignore:unused_signal
signal game_server_ready
#warning-ignore:unused_signal
signal game_client_requested
#warning-ignore:unused_signal
signal game_client_ready
