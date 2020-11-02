extends Control

signal finished

onready var Controls = $HBC/VBC/TextContainer/HBoxContainer/VBoxContainer/Controls
onready var CharName = $HBC/VBC/TextContainer/HBoxContainer/VBoxContainer/CharName
onready var Text = $HBC/VBC/TextContainer/HBoxContainer/VBoxContainer/CurrentText
onready var Title = $HBC/VBC/Title
onready var ChoiceMenu = $Brancher

onready var PauseButton = $HBC/VBC/TextContainer/HBoxContainer/VBoxContainer/Controls/Pause

export(String, FILE, "*.mtalk ; Dialog files") var dialog = ""

var dialogs : Dictionary = {}
var choices : Dictionary = {}
var matches : Dictionary = {}

var next_node : String = ""
var character_name : String = ""
var name_override : String = "" #For use with MwNPCs

func _ready():
	load_dialogs(dialog, name_override)
	

func load_dialogs(dialog : String, name_override : String = ""):
	var conf = ConfigFile.new()
	conf.load(dialog)
	character_name = name_override
	if name_override == "":
		character_name = conf.get_value("config", "character_name")
	
	if conf.has_section("dialogs"):
		for key in conf.get_section_keys("dialogs"):
			dialogs[key] = conf.get_value("dialogs", key)

	if conf.has_section("choices"):
		for key in conf.get_section_keys("choices"):
			choices[key] = conf.get_value("choices_triggers", key)
	
	if conf.has_section("matches"):
		for key in conf.get_section_keys("matches"):
			matches[key] = conf.get_value("choices_triggers", key)

	for connection in conf.get_value("config", "connections"):
		if connection.get("from") == "Start":
			var temp = evaluate_node(connection.get("to"))
			if temp is GDScriptFunctionState:
				next_node = yield(temp, "completed")
			elif temp is String:
				next_node = temp
	
	
func evaluate_node(node : String) -> String:
	if node == "":
		self.visible = false
		emit_signal("finished")
	if dialogs.has(node):
		set_name(dialogs.get(node).get("name_override"))
		set_text(dialogs.get(node).get("content"))
		set_title(dialogs.get(node).get("title"))
		return dialogs.get(node).get("next")
	
	if matches.has(node):
		var answer = yield(ChoiceMenu.get_text_answer(), "completed")
		for options in matches.get(node):
			if answer == options.get("name"):
				return evaluate_node(options.get("triggers"))
				
	
	if choices.has(node):
		var answer = yield(ChoiceMenu.get_multi_answer(choices.get(node)), "completed")
		return evaluate_node(answer)
	
	return ""

func hide_controls():
	Controls.hide()

func set_name(charname : String) -> void:
	if charname == "":
		CharName.text = character_name
		return
	CharName.text = charname

func set_text(text : String) -> void:
	Text.text = text

func set_title(title : String) -> void:
	Title.text = title

func _on_Auto_pressed():
	if PauseButton.pressed:
		return
	yield(get_tree().create_timer(10*Text.text.length()),"timeout")
	var temp = evaluate_node(next_node)
	if temp is GDScriptFunctionState:
		next_node = yield(temp, "completed")
	elif temp is String:
		next_node = temp
	_on_Auto_pressed()

func _on_Skip_pressed():
	if PauseButton.pressed:
		return
	var temp = evaluate_node(next_node)
	yield(get_tree().create_timer(0.1),"timeout")
	if temp is GDScriptFunctionState:
		next_node = yield(temp, "completed")
	elif temp is String:
		next_node = temp
	_on_Skip_pressed()

func _on_Next_pressed():
	var temp = evaluate_node(next_node)
	if temp is GDScriptFunctionState:
		next_node = yield(temp, "completed")
	elif temp is String:
		next_node = temp
	
