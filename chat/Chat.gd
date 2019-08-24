extends Control

signal disable_movement()
var chat_visible = true
var show_duration = 5.0
var timer = show_duration

func _ready():
	gamestate.connect("user_name_disconnected", self, "_player_disconnected")
	gamestate.connect("user_name_connected" , self, "_player_connected")
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_end")
	
func _on_animation_end(ANname):
	if ANname == "FadeOut":
		chat_visible = false
		self.hide()
	

func _process(delta):
	if chat_visible and not $VBoxContainer/ChatInput.has_focus():
		timer -= delta
		if timer <= 0.0:
			$AnimationPlayer.play("FadeOut")
			$VBoxContainer/ChatInput.mouse_filter = Control.MOUSE_FILTER_IGNORE
			

func _player_connected(name):
	var msg = "%s has joined" % name #clean if name is null
	AddMessage(msg)

func _player_disconnected(name):
	var msg = "%s has left" % name #clean if name is null
	AddMessage(msg)

func _connected_ok():
	AddMessage('You have joined the room')
	rpc('announce_user', gamestate.player_get("name"))

sync func display_message(player, new_text):
	AddMessage(player + ' : ' + new_text)
	
remote func announce_user(player):
	AddMessage(player + ' has joined the room')

func _input(event):
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	if event.is_action_pressed("toggle_chat"):
		if UIManager.request_focus():
			ShowChat()
			if not $VBoxContainer/ChatInput.has_focus():
				$VBoxContainer/ChatInput.grab_focus()
		elif chat_visible:
			UIManager.release_focus()
			if not $VBoxContainer/ChatInput.text == "":
				rpc('display_message', gamestate.player_get("name"), $VBoxContainer/ChatInput.text)
			$VBoxContainer/ChatInput.release_focus()
			$VBoxContainer/ChatInput.clear()

func ShowChat():
	if not chat_visible:
		self.show()
		$AnimationPlayer.play("FadeIn")
	$VBoxContainer/ChatInput.mouse_filter = Control.MOUSE_FILTER_STOP
	timer = show_duration
	chat_visible = true

func AddMessage(var message):
	$VBoxContainer/Log.add_text(message)
	$VBoxContainer/Log.newline()
	ShowChat()
