extends FuncRef
class_name Function

func _init(instance : Object, function : String):
	assert(instance!=null)
	set_instance(instance)
	set_function(function)

func execute(variants : Array):
	if is_valid():
		call_funcv(variants)
