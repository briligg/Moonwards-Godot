extends Control

var scripts = {
	Updater = preload("res://core/update/scripts/Updater.gd")
}

var Updater
func _ready():
	printd("Panel update status, tree %s" % get_tree())
	#Go()

func Go():
	Updater = scripts.Updater.new()
	Updater.root_tree = get_tree()
	#UpdateStatus()
	UpdateStatus_ccu_signal()

func set_label(label, text):
	label.text = "%s: %s" % [label.text.split(":")[0], text]

func UpdateStatus():
	printd("UpdateStatus")
	var res = Updater.ui_ClientCheckUpdate()
	var counter = 0
	var counter_max = 100
	var l = $Panel/VBoxContainer/Status
	while(res["state"] == "gathering" and counter <= counter_max):
		yield(get_tree().create_timer(0.5), "timeout")
		res = Updater.ui_ClientCheckUpdate()
		SetLabels(res)
		counter += 1
		set_label(l, "%s/%s" % [counter, counter_max])
		printd("counter: %s" % counter)

	SetLabels(res)
	
	if counter > counter_max:
		l = $Panel/VBoxContainer/Error
		set_label(l, "internal error, update timeout")
		return
	printd("end gathering: %s" % res)

func UpdateStatus_ccu_signal():
	printd("UpdateStatus")
	var res = Updater.ui_ClientCheckUpdate()
	SetLabels(res)
	if res["state"] == "gathering":
		yield(Updater, "chain_ccu")
		res = Updater.ui_ClientCheckUpdate()
		SetLabels(res)
	printd("end gathering: %s" % res)

func SetLabels(res):
	var l
	l = $Panel/VBoxContainer/Error
	if res["error"] == "":
		set_label(l, "ok")
	else:
		set_label(l, res["error"])

	l = $Panel/VBoxContainer/Status
	set_label(l, res["state"])
	
	var st
	l = $Panel/VBoxContainer/Server
	match res["server_online"]:
		true:
			st = "online"
		false:
			st = "offline"
		null:
			st = "unknown"
	set_label(l, st)
	
	l = $Panel/VBoxContainer/UClient
	match res["update_client"]:
		true:
			st = "yes"
		false:
			st = "no"
		null:
			st = "unknown"
	set_label(l, st)
	
	l = $Panel/VBoxContainer/UData
	match res["update_data"]:
		true:
			st = "yes"
		false:
			st = "no"
		null:
			st = "unknown"
	set_label(l, st)

	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

func UpdateData():
	var l = $Panel/VBoxContainer/DowloadDataButton
	var res = Updater.ui_ClientUpdateData()
	if res:
		pass

func _on_DowloadDataButton_pressed():
	UpdateData()

func _on_Button_pressed():
	Go()

var debug_id = "PanelUpdate"
func printd(s):
	logg.print_filtered_message(debug_id, s)


#checksum noise
