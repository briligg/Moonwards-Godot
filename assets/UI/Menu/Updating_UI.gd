extends PanelContainer

var scripts = {
	Updater = preload("res://core/update/scripts/Updater.gd")
}
var Updater

signal update_finished(result)

func AddLogMessage(var text : String):
	if not self.visible:
		self.visible = true
	$"HBoxContainer/TabContainer/Update log/VBoxContainer3/Panel/ScrollContainer/RichTextLabel".text += text + "\n"
	
func set_state(text):
	
	AddLogMessage(str(text))

func set_progress_state(text):

	var label = $HBoxContainer/VBoxContainer/State
	label.text = text
	


func _on_update():
	UpdateData()
	$HBoxContainer/VBoxContainer/HBoxContainer/Button2.disabled = true
	yield(Updater, "chain_cdu")
	$HBoxContainer/VBoxContainer/HBoxContainer/Button2.disabled = false
	$HBoxContainer/VBoxContainer/HBoxContainer/Button2.text = "Return"
	Updater.ClientCloseConnection()


func fn_network_ok():

	AddLogMessage("Initiating network: ok")

func fn_network_fail():

	AddLogMessage("Initiating network failed")

func fn_server_connected():

	AddLogMessage( "Server connected")
	Updater.ClientCheckForServer()

func fn_server_disconnected():

	AddLogMessage( "Server disconnected")
	
func fn_server_fail_connecting():

	AddLogMessage( "Connection fail")

func fn_server_online():

	AddLogMessage( "Server online")
	Updater.ClientCheckProtocol()
	
func fn_server_offline():

	AddLogMessage( "Server offline")
	
func fn_client_protocol(state):

	if state:
		AddLogMessage( "correct version")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		Updater.ClientCheckForUpdate()
	else:
		AddLogMessage("client update is required")
		Updater.ClientCloseConnection()

func fn_update_no_update():

	AddLogMessage( "up to date")
	Updater.ClientCloseConnection()

func fn_update_to_update():
	
	AddLogMessage( "update available")
	#$VBoxContainer/ClientStatus/StartUpdate.disabled = false
	

func fn_update_progress(percent):
	$HBoxContainer/VBoxContainer/ProgressBar.value = percent

func fn_update_finished():
	set_progress_state("Update finished")

func fn_error(msg):
	AddLogMessage(msg)
	set_progress_state("An error has occurred")
	pass

func fn_server_update_done():
	set_progress_state("Server update finished")
	
func fn_client_update_done():
	set_progress_state("Client update finished")
	
func _ready():
	Updater = scripts.Updater.new()
	Updater.SERVER_IP = "208.113.167.237"
	Updater.connect("receive_update_message", self, "AddLogMessage")
	Updater.root_tree = get_tree()
	var signals = [ 
		"network_ok",
		"network_fail",
		"client_protocol",
		"server_connected",
		"server_disconnected",
		"server_fail_connecting",
		"server_online",
		"server_offline",
		"update_ok",
		"update_fail",
		"update_no_update",
		"update_progress",
		"update_finished",
		"server_update_done",
		"client_update_done",
		"error"
	]
	for sg in signals:
		Updater.connect(sg, self, "fn_%s" % sg)

func UpdateData():
	Updater.ClientOpenConnection()
	var res = Updater.ui_ClientUpdateData()
	if res:
		pass

var debug_id = "UI: Updater"

func printd(s):
	logg.print_fd(debug_id, s)
	
