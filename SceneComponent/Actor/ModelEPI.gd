extends EPIBase
class_name ModelEPI


export(PoolStringArray) var fields : PoolStringArray = PoolStringArray()
var field_data_array : Array = []


func _ready() -> void :
	for field in fields :
		field_data_array.append(_get_default_type(field))

func _get_default_type(field_name : String) :
	var check : String = field_name.right(field_name.find("_", 0) + 1)
	if check == "Color" :
		return Color(1,1,1,1)
	elif check == "Bool" :
		return true
	elif check == "Int" :
		return 0
	else :
		#Crash if the field is not inputted correctly.
		Log.critical(self, "_get_default_type", "Field entry %s in epi %s is invalid." % [field_name, get_path() ])
		assert(true == false)
		return
