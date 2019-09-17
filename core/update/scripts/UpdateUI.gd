extends Control

func _ready():
	options.Updater.connect("receive_update_message", self, "AddLogMessage")
	options.Updater.root_tree = get_tree()
# 	Updater.RunUpdateClient()

func AddLogMessage(var text):
	if not self.visible:
		self.visible = true
	$VBoxContainer/VBoxContainer/RichTextLabel.text += text + "\n"

func SwitchScene():
	get_tree().change_scene(ProjectSettings.get_setting("application/run/main_scene"))

func RunUpdateServer():
	$VBoxContainer/VBoxContainer/State.text = "Server"
	$VBoxContainer/ClientStatus.visible = false
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	options.Updater.RunUpdateServer()

func RunUpdateClient():
	options.Updater.LoadPackages()
	options.Updater.ClientUpdateFilter()
	$VBoxContainer/VBoxContainer/State.text = "Client"
	yield(get_tree(), "idle_frame")

	ConnectSignals()
	$VBoxContainer/ClientStatus.visible = true
	yield(get_tree(), "idle_frame")

	#Updater.SERVER_IP = "208.113.167.237"
# 	Updater.ClientOpenConnection()
# 	Updater.RunUpdateClient()
	options.Updater.ui_ClientCheckUpdate()

func ConnectSignals(con = true, prefix="fn_", signals=null):
	#connect signals
	if signals == null:
		signals = [ "network_ok",
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
						"error"]
	for sg in signals:
		var fname = "%s%s" % [prefix, sg]
		if con:
			if not options.Updater.is_connected(sg, self, fname):
				printd("connect %s %s" % [fname, sg])
				options.Updater.connect(sg, self, fname)
		else:
			if options.Updater.is_connected(sg, self, fname):
				printd("disconnect %s %s" % [fname, sg])
				options.Updater.disconnect(sg, self, fname)


func set_label(label, text):
	label.text = "%s: %s" % [label.text.split(":")[0], text]

func fn_network_ok():
	var l = $VBoxContainer/ClientStatus/Network
	set_label(l, "ok")

func fn_network_fail():
	var l = $VBoxContainer/ClientStatus/Network
	set_label(l, "fail")
	ConnectSignals(false)

func fn_server_connected():
	var l = $VBoxContainer/ClientStatus/Server
	set_label(l, "connected")
# 	Updater.ClientCheckForServer()

func fn_server_disconnected():
	var l = $VBoxContainer/ClientStatus/Server
	set_label(l, "disconnected")
	ConnectSignals(false)
	
func fn_server_fail_connecting():
	var l = $VBoxContainer/ClientStatus/Server
	set_label(l, "fail")
	ConnectSignals(false)

func fn_server_online():
	var l = $VBoxContainer/ClientStatus/ServerStatus
	set_label(l, "online")
# 	Updater.ClientCheckProtocol()
	
func fn_server_offline():
	var l = $VBoxContainer/ClientStatus/ServerStatus
	set_label(l, "offline")
	ConnectSignals(false)
	
func fn_client_protocol(state):
	var l = $VBoxContainer/ClientStatus/Protocol
	if state:
		set_label(l, "correct version")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
# 		Updater.ClientCheckForUpdate()
	else:
		set_label(l, "client update is required")
# 		Updater.ClientCloseConnection()
		ConnectSignals(false)

func fn_update_no_update():
	var l = $VBoxContainer/ClientStatus/Update
	set_label(l, "up to date")
# 	Updater.ClientCloseConnection()
	ConnectSignals(false)

func fn_update_to_update():
	var l = $VBoxContainer/ClientStatus/Update
	set_label(l, "update available")
	$VBoxContainer/ClientStatus/StartUpdate.disabled = false
# 	Updater.ClientCloseConnection()
	ConnectSignals(false)

func fn_update_progress(percent):
	$VBoxContainer/ClientStatus/Progress.text = "Progress: " + str(percent)
	printd("progress %s" % percent)

func fn_update_finished():
	printd("update finished")

func fn_error(msg):
	pass

func UpdateData():
	ConnectSignals()
	options.Updater.ClientOpenConnection()
	var l = $VBoxContainer/ClientStatus/StartUpdate
	set_label(l, "processing")
	var res = options.Updater.ui_ClientUpdateData()
	if res:
		pass

func _on_StartUpdate_pressed():
	UpdateData()

var debug_id = "UpdaterUI"
func printd(s):
	logg.print_filtered_message(debug_id, s)
