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
	set_name(Options.username)


func set_name(name : String = "") -> void:
	if name == "":
		name = NameGenerator.get_name()
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
	var players = Lobby.get_player_list()
	players.sort()
	$PlayersList/list.clear()
	$PlayersList/list.add_item(Lobby.get_player_name() + " (You)")
	for p in players:
		$PlayersList/list.add_item(p)
	$PlayersList/start.disabled=not get_tree().is_network_server()

func _on_host_pressed() -> void:
	if ($connect/name.text == ""):
		$connect/error_label.text="Invalid name!"
		return
	var player_data = {
		username = $connect/name.text,
		gender = Options.gender,
		colors = {"pants" : Options.pants_color, "shirt" : Options.shirt_color, "skin" : Options.skin_color, "hair" : Options.hair_color, "shoes" : Options.shoes_color}
	}
	Lobby.connect_to_server(player_data, true, "localhost")
	state_hide()


func _on_join_pressed() -> void:
	if ($connect/name.text == ""):
		$connect/error_label.text="Invalid name!"
		return
	var player_data = {
		username = $connect/name.text,
		gender = Options.gender,
		colors = {"pants" : Options.pants_color, "shirt" : Options.shirt_color, "skin" : Options.skin_color, "hair" : Options.hair_color, "shoes" : Options.shoes_color}
	}
	Lobby.connect_to_server(player_data, false, $connect/ipcontainer/ip.text)
	state_hide()

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
	$connect/join.disabled=false

func _on_game_error(errtxt) -> void:
	$error.dialog_text = errtxt
	$error.popup_centered_minsize()

func _on_Sinlgeplayer_pressed() -> void:
	var worldscene = Options.scenes.default
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return
	var player_data = {
		username = $connect/name.text,
		network = false
	}
	Lobby.NetworkState = Lobby.MODE.ERROR
	Lobby.player_register(player_data, true) #local player
	Log.hint(self, "_on_Singleplayer_pressed", str("change scene to" , worldscene))
	yield(get_tree().create_timer(2), "timeout")
	state_hide()
	Lobby.change_scene(worldscene)

func _on_Button2_pressed() -> void:
	set_name()
	yield(get_tree().create_timer(0.1), "timeout")
