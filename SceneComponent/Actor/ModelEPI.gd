extends EPIBase
class_name ModelEPI

signal field_set(field_name_string, value_variable)
const FIELD_SET : String = "field_set"

#What all fields there are. Fields names are written as strings like so: CamelCaseVariableName_Type
#Underscore should only be for differentiating the variable name from it's declared type.
export(PoolStringArray) var fields : PoolStringArray = PoolStringArray()
var field_data_array : Array = []

#Called at component start to set the model.
onready var model : Spatial = $Model setget set_model, get_model

#Temporary placement of animation node holders.
var animation : AnimationPlayer
var animation_tree : AnimationTree

var visible : bool = true setget set_model_visibility, get_model_visibility


func _ready() -> void :
	for field in fields :
		field_data_array.append(_get_default_type(field))

#Get what type of variable a field is based on it's field string.
func _get_default_type(field_name : String) :
	var check : String = field_name.right(field_name.find("_", 0) + 1)
	if check == "Color" :
		return Color(1,1,1,1)
	elif check == "Bool" :
		return true
	elif check == "Int" :
		return 0
	elif check == "Array" :
		return []
	else :
		#Crash if the field is not inputted correctly.
		Log.critical(self, "_get_default_type", "Field entry %s in epi %s is invalid." % [field_name, get_path() ])
		assert(true == false)
		return

#Try to set a field but only give an error if the field is not present.
func assume_set_field(field_name : String, value) -> void :
	var at : int = _find_field(field_name)
	if at == - 1 :
		Log.error(self, "assume_set_field", "Tried to assign %s field to value %s in %s but field was not there" % [field_name, str(value), get_path()])
		return
	
	#We do have the field so set it to the passed value argument.
	field_data_array[at] = value
	emit_signal(FIELD_SET, value)

func demand_get_field(field_name) :
	var at : int = _find_field(field_name)
	if at == - 1 :
		Log.critical(self, "demand_set_field", "%s had the field %s demanded to be set but field was not there" % [get_path(), field_name])
		assert(true == false) #Make sure to crash when debugging.
		return
	
	return field_data_array[at]

#For when that field must be present for everything to work correctly. Crash if field is not present.
func demand_set_field(field_name : String, value) -> void :
	var at : int = _find_field(field_name)
	if at == - 1 :
		Log.critical(self, "demand_set_field", "%s had the field %s demanded to be set but field was not there" % [get_path(), field_name])
		assert(true == false) #Make sure to crash when debugging.
		return
	
	#We have the field so set it to the passed value argument.
	field_data_array[at] = value
	emit_signal(FIELD_SET, value)

func get_model() :
	return model

func get_model_visibility() -> bool :
	return visible

func request_get_field(field_name) :
	var at : int = _find_field(field_name)
	if at == -1 :
		return _get_default_type(field_name)
	
	return field_data_array[at]

#Intended for calling outside the entity. Does not emit an error or crash if the field is not present.
func request_set_field(field_name : String, value) -> void :
	var at : int = _find_field(field_name)
	if at == -1 :
		return
	
	#We do have the field so set it to the passed value argument.
	field_data_array[at] = value
	emit_signal(FIELD_SET, value)

#Set the animation player from a component.
func set_animation_player(new_animation_player : AnimationPlayer) -> void :
	animation = new_animation_player

#Set the animation tree from a component.
func set_animation_tree(new_animation_tree : AnimationTree) -> void :
	animation_tree = new_animation_tree

#Set the model from a component.
func set_model(new_model) -> void :
	model = new_model

func set_model_visibility(become_visible : bool) -> void :
	model.visible = become_visible

func _find_field(field_name) -> int :
	var at : int = 0
	for field in fields :
		if field == field_name :
			return at
		at += 1
	return -1
