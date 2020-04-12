extends Node
class_name EnumHelper
	
func has_flag(val: int, flag: int) -> bool: 
	if (val & flag) != 0:
		return true
	return false
