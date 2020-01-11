extends Control

enum STATE {
	INIT,
	SERVER_SELECT, # WAITING FOR SUCESS ON SERVER_SELECT
	CLIENT_CONNECT, #WAITING FOR CLIENT CONNECTION
	LAST_RECORD
}

onready var ServerWait = $WaitServer/Label.text

#The input field for choosing the player's name.
onready var player_name_box : LineEdit = get_node( "connect/namecontainer/name_input" )

var state = STATE.INIT setget set_state
var binddef : Dictionary = { src = null, dest = null }

func _ready() -> void:
	set_name_box(Options.username)

func bind_to_node_utilities() -> void :
	#Bind myself to the node utilities so that I can listen to errors and reports.
	NodeUtilities.bind_signal("network_log", "", GameState, self, NodeUtilities.MODE.CONNECT)
	NodeUtilities.bind_signal("server_up", "", GameState, self, NodeUtilities.MODE.CONNECT)
	NodeUtilities.bind_signal("network_error", "", GameState, self, NodeUtilities.MODE.CONNECT)

func is_valid_connection() -> bool :
	#When trying to connect, check that everything is as it should be.
	if not (GameState.RoleServer or GameState.RoleClient):
		if (player_name_box.text == ""):
			$connect/error_label.text="Invalid name!"
			return false
	
	else:
		emit_signal("network_error", "Already in server or client mode")
	
	#Connection is valid.
	return true

func register_player_local() -> void :
	#Register the player with the game state.
	var player_data = {
		username = player_name_box.text,
		gender = Options.gender,
		colors = {"pants" : Options.pants_color, "shirt" : Options.shirt_color, "skin" : Options.skin_color, "hair" : Options.hair_color, "shoes" : Options.shoes_color}
	}
	GameState.player_register(player_data, true) #local player

func save_name( new_name : String ) -> void :
	#Called whenever the player inputs text in the name box.
	Options.username = new_name

func set_name_box(name : String = "") -> void:
	if name == "":
		name = Utilities.get_name()
	player_name_box.text = name

func state_hide() -> void:
	match state:
		STATE.INIT:
			$connect.hide()
		STATE.SERVER_SELECT:
			$WaitServer.hide()
		STATE.CLIENT_CONNECT:
			$WaitServer.hide()

func state_show() -> void:
	match state:
		STATE.INIT:
			$connect.show()
		STATE.SERVER_SELECT:
			$WaitServer/Label.text = "Setting the server up:\n"
			$WaitServer.show()
		STATE.CLIENT_CONNECT:
			$WaitServer/Label.text = "Connecting to server:\n"
			$WaitServer.show()

func set_state(nstate : int)-> void:
	state_hide()
	state = nstate
	state_show()

func refresh_lobby() -> void:
	var players = GameState.get_player_list()
	players.sort()
	$PlayersList/list.clear()
	$PlayersList/list.add_item(GameState.get_player_name() + " (You)")
	for p in players:
		$PlayersList/list.add_item(p)
	$PlayersList/start.disabled=not get_tree().is_network_server()

func _on_network_log(msg : String) -> void:
	ServerWait = "%s%s\n" % [$WaitServer/Label.text, msg]
	Log.hint(self, "_on_network_log", msg)

func _on_server_up() -> void:
	var worldscene = Options.scenes.default_multiplayer_scene
	_on_network_log("change scene to %s" % worldscene)
	yield(get_tree().create_timer(2), "timeout")
	state_hide()
	GameState.change_scene(worldscene)

func _on_network_error(msg : String) -> void:
	var oldstate = state
	set_state(STATE.INIT)
	match oldstate:
		STATE.SERVER_SELECT:
			$connect/error_label.text = "Error setting server : %s" % msg
		STATE.CLIENT_CONNECT:
			$connect/error_label.text = msg

func _on_server_connected() -> void:
	_on_server_up()

func _on_host_pressed() -> void:
	if is_valid_connection() == false :
		return
	
	self.register_player_local()

	self.set_state( STATE.SERVER_SELECT )
	
	self.bind_to_node_utilities()

	GameState.server_set_mode()

func _on_join_pressed() -> void:
	#Exit out if the connection is not valid.
	if is_valid_connection() == false :
		return
	
	self.set_state(STATE.CLIENT_CONNECT)
	
	self.register_player_local()

	self.bind_to_node_utilities()

	GameState.client_server_connect($connect/ipcontainer/ip.text)

func _on_connection_success() -> void:
	$connect.hide()
	$PlayersList.show()

func _on_connection_failed() -> void:
	$connect/host.disabled = false
	$connect/join.disabled = false
	$connect/error_label.set_text("Connection failed.")

func _on_game_ended() -> void:
	show()
	$connect.show()
	$PlayersList.hide()
	$connect/host.disabled=false
	$connect/join.disabled

func _on_game_error(errtxt) -> void:
	$error.dialog_text = errtxt
	$error.popup_centered_minsize()

func _on_start_pressed() -> void:
	GameState.begin_game()
	hide()

func _on_Sinlgeplayer_pressed() -> void:
	var worldscene = Options.scenes.default_singleplayer_scene
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return
	var player_data = {
		username = player_name_box.text,
		network = false
	}
	GameState.RoleNoNetwork = true
	GameState.player_register(player_data, true) #local player
	Log.hint(self, "_on_Singleplayer_pressed", str("change scene to" , worldscene))
	yield(get_tree().create_timer(2), "timeout")
	state_hide()
	GameState.change_scene(worldscene)
