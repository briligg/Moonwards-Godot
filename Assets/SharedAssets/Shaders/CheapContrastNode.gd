tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeColorHue

func _get_name() -> String:
	return "ColorHue"

func _get_category() -> String:
	return "Color"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs a cheap contrast based on error"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count() -> int:
	return 2

func _get_input_port_name(port: int):
	match port:
		0:
			return "inp"
		1:
			return "contrast"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "result"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode: int) -> String:
	return """
float ContrastFunc(float _Inp, float _Contrast){
	vec3 a = mix(vec3(0.0 - _Contrast, 0.0 - _Contrast, 0.0 - _Contrast), vec3(1.0 + _Contrast, 1.0 + _Contrast, 1.0 + _Contrast), _Inp);
	return clamp(a.r, 0.0, 1.0);
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = ContrastFunc(%s, %s);" % [output_vars[0], input_vars[0], input_vars[1]]

func _init():
	# Default values for the editor