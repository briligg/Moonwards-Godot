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
	return "Outputs RGB color from Hue"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 1

func _get_input_port_name(port: int):
	match port:
		0:
			return "hue"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "color"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode: int) -> String:
	return """
vec3 GetHue(float _Hue){
	return min(max(3.0 * abs(1.0 - 2.0 * fract(_Hue + vec3(0.0, -1.0 / 3.0, 1.0 / 3.0))) - 1.0 , 0.0), 1.0);
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = GetHue(%s);" % [output_vars[0], input_vars[0]]

func _init():
	# Default values for the editor
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, 1.0)