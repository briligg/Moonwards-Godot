extends Control
"""
	UpdateUI Scene Script
"""
const DEFAULT_SIGNALS: Array = [ "network_ok",
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
		"update_to_update",
		"update_progress",
		"update_finished",
		"error"
		]

onready var _log_label: RichTextLabel = $"V/Left/Log"
onready var _state_label: Label = $"V/Left/State"

onready var _status_container: VBoxContainer = $"V/ClientStatus"
onready var _network_label: Label = $"V/ClientStatus/Network"
onready var _server_label: Label = $"V/ClientStatus/Server"
onready var _serverstatus_label: Label = $"V/ClientStatus/ServerStatus"
onready var _protocol_label: Label = $"V/ClientStatus/Protocol"
onready var _update_label: Label = $"V/ClientStatus/Update"
onready var _update_button: Button = $"V/ClientStatus/StartUpdate"
onready var _progress_label: Label = $"V/ClientStatus/Progress"


func _ready() -> void:
	options.Updater.connect("receive_update_message", self, "_on_update_message_recieved")
	options.Updater.root_tree = get_tree()
# 	Updater.RunUpdateClient()


func run_update_server() -> void:
	_state_label.text = "Server"
	_status_container.visible = false
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	options.Updater._run_update_server()


func _connect_signals() -> void:
	for signal_name in DEFAULT_SIGNALS:
		var func_name: String = get_signal_function_name(signal_name)
		
		if not options.Updater.is_connected(signal_name, self, func_name):
			_printd("connect %s %s" % [func_name, signal_name])
			options.Updater.connect(signal_name, self, func_name)


func _disconnect_signals() -> void:
	for signal_name in DEFAULT_SIGNALS:
		var func_name: String = get_signal_function_name(signal_name)
		
		if options.Updater.is_connected(signal_name, self, func_name):
			_printd("disconnect %s %s" % [func_name, signal_name])
			options.Updater.disconnect(signal_name, self, func_name)


func set_control_text(control_with_text: Control, text: String) -> void:
	assert(control_with_text is Label or control_with_text is Button)
	control_with_text.text = "%s: %s" % [control_with_text.text.split(":")[0], text]


func _on_network_ok() -> void:
	set_control_text(_network_label, "ok")


func _on_network_fail() -> void:
	set_control_text(_network_label, "fail")
	_disconnect_signals()


func _on_server_connected() -> void:
	set_control_text(_server_label, "connected")


func _on_server_disconnected() -> void:
	set_control_text(_server_label, "disconnected")
	_disconnect_signals()


func _on_server_fail_connecting() -> void:
	set_control_text(_server_label, "fail")
	_disconnect_signals()


func _on_server_online() -> void:
	set_control_text(_serverstatus_label, "online")


func _on_server_offline() -> void:
	set_control_text(_serverstatus_label, "offline")
	_disconnect_signals()


	# TODO: Confirm type. Bool? Or status code?
func _on_client_protocol(state) -> void:
	if state:
		set_control_text(_protocol_label, "correct version")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
	
	else:
		set_control_text(_protocol_label, "client update is required")
		_disconnect_signals()


func _on_update_no_update() -> void:
	set_control_text(_update_label, "up to date")
	_disconnect_signals()


func _on_update_to_update() -> void:
	set_control_text(_update_label, "update available")
	_update_button.disabled = false
	_disconnect_signals()


	# TODO: Confirm type. String, or number?
func _on_update_progress(percent) -> void:
	_progress_label.text = "Progress: " + str(percent)
	_printd(str("progress ", percent))


func _on_update_finished() -> void:
	_printd("update finished")


	# TODO: Confirm type. Write code.
func _on_error(msg) -> void:
	assert(msg == OK) # See above todo.
	pass


	# TODO: Figure out what, where, how, calls this.
func UpdateData() -> void:
	_connect_signals()
	
	options.Updater.ClientOpenConnection()
	
	set_control_text(_update_button, "processing")
	
	var res = options.Updater.ui_ClientUpdateData()
	# What?
	if res:
		pass


func _on_StartUpdate_pressed() -> void:
	# See above comment
	UpdateData()


	# TODO: Nuke this. Replace with direct calls where used.
	# ID can be provided as constant, or `name`
var debug_id: String = "UpdaterUI"
func _printd(s) -> void:
	logg.print_fd(debug_id, s)


func _on_update_message_recieved(text: String) -> void:
	visible = true
	_log_label.text += str(text, "\n")


static func get_signal_function_name(signal_name: String) -> String:
	return str("_on_", signal_name)
