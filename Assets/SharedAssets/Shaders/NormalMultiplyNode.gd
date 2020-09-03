tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeNormalMultiply

func _get_name() -> String:
	return "NormalMultiply"

func _get_category() -> String:
	return "Vector"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs multiplied normal"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 2

func _get_input_port_name(port: int):
	match port:
		0:
			return "a"
		1:
			return "b"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(_port: int) -> String:
	return "op"

func _get_output_port_type(_port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(_mode: int) -> String:
	return """
vec3 NormalMultFunc(vec3 _Normal, float _Amount){
	return vec3(_Normal.x * _Amount, _Normal.y * _Amount, 1.0);
}
"""

func _get_code(input_vars: Array, output_vars: Array, _mode: int, _type: int) -> String:
	return "%s = NormalMultFunc(%s,%s);" % [output_vars[0], input_vars[0], input_vars[1]]

func _init():
	# Default values for the editor
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, Vector3(0.5,0.5,1.0))
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, 1.0)
