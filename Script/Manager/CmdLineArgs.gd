extends Node

var args: Dictionary = {} setget _set_illegal

func _init():
	for argument in OS.get_cmdline_args():
		print(argument)
		var arg_vals = argument.lstrip("--")
		if argument.find("=") != -1:
			arg_vals = arg_vals.split("=")
			args[arg_vals[0]] = arg_vals[1]
		else:
			args[arg_vals] = true
	#print(args)

func _set_illegal(_val) -> void:
	Log.warnings(self, "_set_cmd", "Set invocation is illegal.")
