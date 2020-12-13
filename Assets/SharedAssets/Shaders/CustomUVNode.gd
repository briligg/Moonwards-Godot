tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeUVEdit

func _get_name() -> String:
	return "UVEdit"

func _get_category() -> String:
	return "Vector"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs edited uv"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 3

func _get_input_port_name(port: int):
	match port:
		0:
			return "uv"
		1:
			return "scale"
		2:
			return "offset"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "vector"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode: int) -> String:
	return """
vec3 GetUVEdited( vec3 _UV, vec3 _Scale, vec3 _Offset ) {
	return vec3((_UV.x * _Scale.x)+_Offset.x, (_UV.y * _Scale.y)+_Offset.y, 0.0);
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = GetUVEdited(%s,%s,%s);" % [output_vars[0],input_vars[0],input_vars[1],input_vars[2]]
	
func _init():
	# Default values for the editor
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, Vector3(0,0,0.0))
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, Vector3(1.0,1.0,1.0))
	if not get_input_port_default_value(2):
		set_input_port_default_value(2, Vector3(0.0,0.0,0.0))
