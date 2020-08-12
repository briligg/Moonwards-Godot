tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeDistanceWS

func _get_name() -> String:
	return "DistanceWS"

func _get_category() -> String:
	return "Vector"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs world distance to vertex"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 2

func _get_input_port_name(port: int):
	match port:
		0:
			return "distance"
		1:
			return "smooth"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "vector"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode: int) -> String:
	return """
float GetWorldDistance( vec3 _Vertex, float _Distance, float _Smooth ) {
	return clamp(smoothstep(_Smooth, _Distance, -_Vertex.z), 0.0, 1.0);
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	return "%s = GetWorldDistance(VERTEX,%s,%s);" % [output_vars[0], input_vars[0], input_vars[1]]

func _init():
	# Default values for the editor
	if not get_input_port_default_value(0):
		set_input_port_default_value(0, 1.0)
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, 0.0)