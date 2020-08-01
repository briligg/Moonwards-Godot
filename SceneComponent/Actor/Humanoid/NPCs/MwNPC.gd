extends NPCBase

"""
This is the actual class to be edited, extends the NPCBase and has the functions
that appear in the Definitions file.
"""

signal user_input(action_name)
signal see()
signal hear()


func property_check(input, signals, variables):
	#input is object, get the specific variable in the variable port and then
	#passes it to the next node
	var filter = get_variable_from_port(variables, 1)
	if input.has(filter):
		emit_signal_from_port(input.get(filter), signals, 0)

func match(input, signals, variables):
	#Checks if input matches with the variable input, if it does
	#calls the next node
	if input == get_variable_from_port(variables, 1):
		emit_signal_from_port(true, signals, 0)

func parallel_trigger(input, signals, variables):
	#Takes the contents of a signal and distributes it along other two nodes
	emit_signal_from_port(input, signals, 0)
	emit_signal_from_port(input, signals, 1)

func force_next_state(input, signals, variables):
	emit_signal("next_state", true)

func tri_v_decision(input, signals, variables):
	var weight1 = get_variable_from_port(variables, 1)
	var weight2 = get_variable_from_port(variables, 2)
	var weigth3 = get_variable_from_port(variables, 3)
	var maximum = max(weight1, max(weight2, weigth3))
	if maximum == weight1:
		emit_signal_from_port(input, signals, 1)
	elif maximum == weight2:
		emit_signal_from_port(input, signals, 2)
	elif maximum == weigth3:
		emit_signal_from_port(input, signals, 3)

func play_global_sound(input, signals, variables):
	var path = get_variable_from_port(variables, 0)
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = load(path)
	sound_player.connect("finished", sound_player, "queue_free")
	add_child(sound_player)
	sound_player.play()

func play_3d_sound(input, signals, variables):
	var path = get_variable_from_port(variables, 0)
	var sound_player = AudioStreamPlayer3D.new()
	sound_player.stream = load(path)
	sound_player.connect("finished", sound_player, "queue_free")
	add_child(sound_player)
	sound_player.play()

func trigger_dialog(input, signals, variables):
	pass
