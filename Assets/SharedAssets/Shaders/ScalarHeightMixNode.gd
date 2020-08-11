tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeScalarHeightMix

func _get_name() -> String:
	return "ScalarHeightMix"

func _get_category() -> String:
	return "Scalar"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs mixed scalars height based"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 5

func _get_input_port_name(port: int):
	match port:
		0:
			return "a"
		1:
			return "b"
		2:
			return "weight"
		3:
			return "height"
		4:
			return "contrast"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "mix"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode: int) -> String:
	return """
float ContrastFunc(float _Inp, float _Contrast){
	vec3 a = mix(vec3(0.0 - _Contrast, 0.0 - _Contrast, 0.0 - _Contrast), vec3(1.0 + _Contrast, 1.0 + _Contrast, 1.0 + _Contrast), _Inp);
	return clamp(a.r, 0.0, 1.0);
}

float HeightLerp(float _A, float _B, float _Weight, float _Height, float _Contrast){
	float contrast = ContrastFunc(clamp(_Height - 1.0) + (_Weight * 2.0), 0.0, 1.0), _Contrast);
	return mix(_A, _B, contrast);
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = HeightLerp(%s);" % [output_vars[0], input_vars[0], input_vars[1], input_vars[2], input_vars[3], input_vars[4]]

func _init():
	# Default values for the editor
	if not get_input_port_default_value(4):
		set_input_port_default_value(4, 0.5)
