extends LineEdit


func _gui_input(event):
	if not event is InputEventKey :
		return
	
	#Mark the received input as handled to prevent 
	#other nodes from reading it.
	get_tree().get_root().set_input_as_handled() 
	
	#When event is return key, let everyone know that we have finished typing.
	if event.is_action_pressed("start_typing_chat") :
		Signals.Hud.emit_signal(Signals.Hud.CHAT_TYPING_FINISHED)

#Prevent accidental inputs from being read.
func _ready() -> void :
	set_process_input(false)

#Called from Chat. Start processsing input.
func start() -> void :
	set_process_input(true)
