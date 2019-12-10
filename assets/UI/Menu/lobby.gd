extends Control

enum STATE {
	INIT,
	SERVER_SELECT, # WAITING FOR SUCESS ON SERVER_SELECT
	CLIENT_CONNECT, #WAITING FOR CLIENT CONNECTION
	LAST_RECORD
}

onready var ServerWait = $WaitServer/Label.text

var state = STATE.INIT setget set_state
var binddef : Dictionary = { src = null, dest = null }

func _ready() -> void:
	set_name(options.username)


func set_name(name : String = "") -> void:
	if name == "":
		name = namelist.get_name()
	$connect/name.text = name
	
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
	var players = gamestate.get_player_list()
	players.sort()
	$PlayersList/list.clear()
	$PlayersList/list.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		$PlayersList/list.add_item(p)
	$PlayersList/start.disabled=not get_tree().is_network_server()

func _on_network_log(msg : String) -> void:
	ServerWait = "%s%s\n" % [$WaitServer/Label.text, msg]
	Log.hint(self, "_on_network_log", msg)

func _on_server_up() -> void:
	var worldscene = options.scenes.default_multiplayer_scene
	_on_network_log("change scene to %s" % worldscene)
	yield(get_tree().create_timer(2), "timeout")
	state_hide()
	gamestate.change_scene(worldscene)

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
	if not (gamestate.RoleServer or gamestate.RoleClient):
		if ($connect/name.text == ""):
			$connect/error_label.text="Invalid name!"
			return
		var player_data = {
			username = $connect/name.text,
			gender = options.gender,
			colors = {"pants" : options.pants_color, "shirt" : options.shirt_color, "skin" : options.skin_color, "hair" : options.hair_color, "shoes" : options.shoes_color}
		}
		gamestate.player_register(player_data, true) #local player
		self.state = STATE.SERVER_SELECT
		
		utils.bind_signal("network_log", "", gamestate, self, utils.MODE.CONNECT)
		utils.bind_signal("server_up", "", gamestate, self, utils.MODE.CONNECT)
		utils.bind_signal("network_error", "", gamestate, self, utils.MODE.CONNECT)
		
		
		gamestate.server_set_mode()
	else:
		emit_signal("network_error", "Already in server or client mode")

func _on_join_pressed() -> void:
	if not (gamestate.RoleServer or gamestate.RoleClient):
		if ($connect/name.text == ""):
			$connect/error_label.text="Invalid name!"
			return

		set_state(STATE.CLIENT_CONNECT)
		var player_data = {
			username = $connect/name.text,
			gender = options.gender,
			colors = {"pants" : options.pants_color, "shirt" : options.shirt_color, "skin" : options.skin_color, "hair" : options.hair_color, "shoes" : options.shoes_color}
		}
		gamestate.player_register(player_data, true) #local player
		
		utils.bind_signal("network_log", "", gamestate, self, utils.MODE.CONNECT)
		utils.bind_signal("server_up", "", gamestate, self, utils.MODE.CONNECT)
		utils.bind_signal("network_error", "", gamestate, self, utils.MODE.CONNECT)
		
		gamestate.client_server_connect($connect/ipcontainer/ip.text)
		return
	else: 
		emit_signal("network_error", "Already in server or client mode")

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
	gamestate.begin_game()
	hide()

func _on_Sinlgeplayer_pressed() -> void:
	var worldscene = options.scenes.default_singleplayer_scene
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return
	var player_data = {
		username = $connect/name.text,
		network = false
	}
	gamestate.RoleNoNetwork = true
	gamestate.player_register(player_data, true) #local player
	Log.hint(self, "_on_Singleplayer_pressed", str("change scene to" , worldscene))
	yield(get_tree().create_timer(2), "timeout")
	state_hide()
	gamestate.change_scene(worldscene)

func _on_Button2_pressed() -> void:
	set_name()
	yield(get_tree().create_timer(0.1), "timeout")
