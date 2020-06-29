extends NPCBase

func trivalent_decision(input, signals, variables):
	var weight_1 = get_var_or_meta(get_variable_from_port(variables, 1))
	var weight_2 = get_var_or_meta(get_variable_from_port(variables, 2))
	var weight_3 = get_var_or_meta(get_variable_from_port(variables, 3))
	if weight_1 == null or weight_2 == null or weight_3 == null:
		return
	var prevalent = max(max(weight_1,weight_2),weight_3)
	#prevalent will be the stronger weight
	if prevalent == weight_1:
		emit_signal_from_port(input, signals, 1)
	elif prevalent == weight_2:
		emit_signal_from_port(input, signals, 2)
	elif prevalent == weight_3:
		emit_signal_from_port(input, signals, 3)
