extends PanelContainer

signal update_finished(result)

var has_update : bool = false
var set_as_updater : bool = false
var UpdatingUI : String  = "res://assets/UI/Menu/Updating_UI.tscn"
var result : int
var debug_id : String = "About panel"

func _ready() -> void:
	has_update = options.get("Update info", "available", null)
	if has_update:
		set_as_updater = true
		$HBoxContainer2/VBoxContainer3/Update_check.text = "Update"
		_on_update_finished(1)

	options.Updater.connect("update_to_update", self, "_on_update_to_update")
	if not options.get("Update info", "available", null):
		$HBoxContainer2/VBoxContainer3/Version3.text = "Last checked: " 
		var Date : Dictionary = OS.get_datetime()
		var Data_to_show : String = " "
		if options.get("Update info", "day") != null:
			Data_to_show += str(options.get("Update info", "day"),"/")
			Data_to_show += str(options.get("Update info", "month"),"/")
			Data_to_show += str(options.get("Update info", "year" )," ")
			Data_to_show += str(options.get("Update info", "hour" ),":")
			Data_to_show += str(options.get("Update info", "minute"),":")
			Data_to_show += str(options.get("Update info", "second"))

		else:
			Data_to_show += "Not available"
		$HBoxContainer2/VBoxContainer3/Version3.text += Data_to_show
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	connect("update_finished",self,"_on_update_finished")
	
func printd(s) -> void:
	logg.print_fd(debug_id, s)

func check_for_update() -> void:
	$HBoxContainer2/VBoxContainer3/Version3.text = "Gathering update information"
	var res : Dictionary = options.Updater.ui_ClientCheckUpdate()
	
	if res["state"] == "gathering":
		
		yield(options.Updater, "chain_ccu")
		
		
		match res["update_data"]:
			
			true:
				printd("Update available")
				has_update = true
				result = 1
			false:
				printd("No update available")
				has_update = false
				result = 0
			null:
				
				printd("Error occurred")
				result = -1
				has_update = false
	printd("end gathering: %s" % res)
	emit_signal("update_finished", result)

func _on_update_to_update() -> void:
	UIManager.NextUI(UpdatingUI)
	
func _on_update_finished(result : int) -> void:
	var Status = $HBoxContainer2/VBoxContainer3/Version3
	if result == 1:
		Status.add_color_override("font_color",Color("ffff00"))
		Status.text = "There's an update available"
		options.set("Update info", true,"available")
		$HBoxContainer2/VBoxContainer3/Update_check.text = "Update"
	if result == 0:
		Status.text = "There are no updates available"
		options.set("Update info", false,"available")
	if result == -1:
		Status.text = "An error occurred"
		options.set("Update info", null,"available")
	Status.text += "\nLast checked: "
	var Date = OS.get_datetime()
	var Date_to_store = ""
	Date_to_store += str(Date.get("day"))+"/"+str(Date.get("month"))+"/"+str(Date.get("year"))+" at "
	Date_to_store += str(Date.get("hour"))+":"+str(Date.get("minute"))+":"+str(Date.get("second"))
	Status.text += Date_to_store
	options.set("Update info",  str(Date.get("hour")), "hour")
	options.set("Update info",  str(Date.get("minute")), "minute")
	options.set("Update info",  str(Date.get("second")), "second")
	options.set("Update info",  str(Date.get("year")), "year")
	options.set("Update info",  str(Date.get("month")), "month")
	options.set("Update info",  str(Date.get("day")), "day")
	options.save()

func _on_Change_log_pressed() -> void:
	$Change_log.popup_centered()

func _on_Update_check_pressed() -> void:
	if not has_update:
		check_for_update()
#	if has_update and set_as_updater:
#		UIManager.NextUI(UpdatingUI)
#		return
#	Updater.ClientOpenConnection() #just connect
#	Updater.ClientCheckForServer() #protocol ping server
#	Updater.ClientCheckProtocol()  #check version, here where it can be ok or not
#	Updater.ClientCheckForUpdate() #calculates current tree id sends to server and get response if it ok or no
#	Updater.ClientCloseConnection() #sort of important, as server has no function to drop user connection
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	if has_update:
		set_as_updater = true
		_on_update_to_update()
    
func _on_Change_log_confirmed() -> void:
	$Change_log.hide()
