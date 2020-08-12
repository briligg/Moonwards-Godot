tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeLocationWS

func _get_name() -> String:
	return "LocationWS"

func _get_category() -> String:
	return "Vector"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs world location vector"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 0

#func _get_input_port_name(port: int):
#	match port:
#		0:
#			return "hue"

#func _get_input_port_type(port: int):
#	match port:
#		0:
#			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "vector"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode: int) -> String:
	return """
vec3 GetWorldLocation( vec4 _Camera, vec3 _Vertex ) {
	vec4 camx = _Camera[0];
	vec4 camy = _Camera[1];
	vec4 camz = _Camera[2];
	vec4 camw = _Camera[3];
	mat3 cam = mat3(camx.xyz, camy.xyz, camz.xyz);

	return (_Vertex - camw.xyz) * cam;
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = GetWorldLocation(INV_CAMERA_MATRIX,VERTEX);" % [output_vars[0]]

func _init():
	# Default values for the editor
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, 1.0)