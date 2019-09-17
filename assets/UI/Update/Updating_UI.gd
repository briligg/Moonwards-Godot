extends PanelContainer
signal update_finished(result)

var debug_id = "UI: Updater"
var scripts = {
	updater = preload("res://core/update/scripts/Updater.gd")
}
var updater : Node
onready var Log : RichTextLabel = $"HBoxContainer/TabContainer/Update log/VBoxContainer3/Panel/ScrollContainer/RichTextLabel"
onready var buttons : Button = $HBoxContainer/VBoxContainer/HBoxContainer/Button2


func _ready() -> void:
	updater = scripts.updater.new()
	updater.SERVER_IP = "208.113.167.237"
	updater.connect("receive_update_message", self, "AddLogMessage")
	updater.root_tree = get_tree()
	var signals : Array = [ 
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
	for _signal in signals:
		updater.connect(_signal, self, str("_on_", _signal))

func add_log_message(var text : String) -> void:

	if not visible:
		visible = true
	Log.text += text + "\n"
	
func set_state(text) -> void:
	
	add_log_message(str(text))

func set_progress_state(text) -> void:

	var label = $HBoxContainer/VBoxContainer/State
	label.text = text
	


func _on_update() -> void:
	update_data()
	buttons.disabled = true
	yield(updater, "chain_cdu")
	buttons.disabled = false
	buttons.text = "Return"
	updater.ClientCloseConnection()


func _on_network_ok() -> void:

	add_log_message("Initiating network: ok")

func _on_network_fail() -> void:

	add_log_message("Initiating network failed")

func _on_server_connected() -> void:

	add_log_message( "Server connected")
	updater.ClientCheckForServer()

func _on_server_disconnected() -> void:

	add_log_message( "Server disconnected")
	
func _on_server_fail_connecting() -> void:

	add_log_message( "Connection fail")

func _on_server_online() -> void:

	add_log_message( "Server online")
	updater.ClientCheckProtocol()
	
func _on_server_offline() -> void:

	add_log_message( "Server offline")
	
func _on_client_protocol(state) -> void:

	if state:
		add_log_message( "correct version")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		updater.ClientCheckForUpdate()
	else:
		add_log_message("client update is required")
		updater.ClientCloseConnection()

func _on_update_no_update() -> void:

	add_log_message( "up to date")
	updater.ClientCloseConnection()

func _on_update_to_update() -> void:
	
	add_log_message( "update available")
	#$VBoxContainer/ClientStatus/StartUpdate.disabled = false
	

func _on_update_progress(percent) -> void:
	$HBoxContainer/VBoxContainer/ProgressBar.value = percent

func _on_update_finished() -> void:
	set_progress_state("Update finished")

func _on_error(msg) -> void:
	add_log_message(msg)
	set_progress_state("An error has occurred")
	pass

func _on_server_update_done() -> void:
	set_progress_state("Server update finished")
	
func _on_client_update_done() -> void:
	set_progress_state("Client update finished")
	

func update_data() -> void:
	updater.ClientOpenConnection()
	var res = updater.ui_ClientUpdateData()
	if res:
		pass


func printd(s) -> void:
	logg.print_filtered_message(debug_id, s)
	
