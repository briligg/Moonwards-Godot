tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeUVPanner

func _get_name() -> String:
	return "UVPanner"

func _get_category() -> String:
	return "Vector"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs moving uv"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 2

func _get_input_port_name(port: int):
	match port:
		0:
			return "uv"
		1:
			return "speed"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "vector"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode: int) -> String:
	return """
vec3 GetUVPanner( vec3 _UV, vec3 _Speed, float _Timer ) {
	return vec3(Timer*_Speed.x)+_UV.x ,(Timer*_Speed.y)+_UV.y, 0.0);
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = GetUVPanner(%s,%s,TIME);" % [output_vars[0],input_vars[0],input_vars[1]]

func _init():
	# Default values for the editor
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, Vector3(UV.x,UV.y,0.0))
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, Vector3(1.0,1.0,0.0))