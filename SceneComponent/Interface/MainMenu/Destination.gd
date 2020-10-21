extends PanelContainer


#These are the signals for the buttons that get pressed.
signal joined_master()
signal joined_server(server_ip_address_string)
signal started_custom_server()

onready var ip_address : TextEdit = $HBoxContainer/VBoxContainer/VBoxContainer/TextEdit_Address

#What the main server IP is.
const MAIN_SERVER_IP : String = "45.77.54.168"
const PORT : int = 5000


func _joined_master() -> void :
	emit_signal("joined_master")
	
	Signals.Network.emit_signal(Signals.Network.GAME_CLIENT_REQUESTED, MAIN_SERVER_IP, PORT)

func _joined_server() -> void :
	var ip : String = ip_address.text
	emit_signal("joined_server", ip)

	#Until we have config files setup.
	Signals.Network.emit_signal(Signals.Network.GAME_CLIENT_REQUESTED, ip, PORT)

func _started_custom_server() -> void :
	emit_signal("started_custom_server")
	Signals.Network.emit_signal(Signals.Network.GAME_SERVER_REQUESTED, PORT)

func _ready() -> void :
	var button : Button
	button = $HBoxContainer/VBoxContainer/Button_JoinServer
	button.connect("pressed", self, "_joined_server")
	
	button = $HBoxContainer/VBoxContainer2/Button_JoinMaster
	button.connect("pressed", self, "_joined_master")
	
	button = $HBoxContainer/VBoxContainer2/Button_CreateServer
	button.connect("pressed", self, "_started_custom_server")
