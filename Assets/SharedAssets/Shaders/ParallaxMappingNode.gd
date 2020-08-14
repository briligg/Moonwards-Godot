tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeParallaxMapping

func _get_name() -> String:
	return "ParallaxMapping"

func _get_category() -> String:
	return "Vector"

#func _get_subcategory():
#	return ""

func _get_description() -> String:
	return "Outputs UV parallax"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count() -> int:
	return 7

func _get_input_port_name(port: int):
	match port:
		0:
			return "uv"
		1:
			return "heightmap"
		2:
			return "ratio"
		3:
			return "steps_min"
		4:
			return "steps_max"
		5:
			return "height_flip"
		6:
			return "height_invert"

func _get_input_port_type(port: int):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SAMPLER
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR
		5:
			return VisualShaderNode.PORT_TYPE_VECTOR
		6:
			return VisualShaderNode.PORT_TYPE_BOOLEAN

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "uv"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR

#Code based on Godot original code https://github.com/godotengine/godot/blob/00949f0c5fcc6a4f8382a4a97d5591fd9ec380f8/scene/resources/material.cpp#L814
func _get_global_code(mode: int) -> String:
	return """
vec3 ParallaxMapping_Simple(vec3 _UV, sampler2D _HeightmapTexture, float _HeightRatio, bool _HeighInverted, float _StepsMin, float _StepsMax, vec3 _HeightmapFlip, vec3 _Vertex, vec3 _Normal, vec3 _Tangent, vec3 _Binormal) {
	vec3 view_dir = normalize(normalize(-_Vertex)*mat3(_Tangent*_HeightmapFlip.x,-_Binormal*_HeightmapFlip.y,_Normal));
	float num_steps = mix(_StepsMax,_StepsMin, abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
	
	float layer_depth = 1.0 / num_steps;
	vec2 p = view_dir.xy * _HeightRatio;
	vec2 delta = p / num_steps;
	vec2 ofs = _UV.xy;
	float depth = 0.0;
	if (_HeighInverted) {
		depth = texture(_HeightmapTexture, ofs).r;
		float current_depth = 0.0;
		while(current_depth < depth) {
			ofs -= delta;
			depth = texture(_HeightmapTexture, ofs).r;
			current_depth += layer_depth;
		}
		vec2 prev_ofs = ofs + delta;
		float after_depth  = depth - current_depth;
		float before_depth = 0.0;
		before_depth = texture(_HeightmapTexture, prev_ofs).r - current_depth + layer_depth;
		float weight = after_depth / (after_depth - before_depth);
		ofs = mix(ofs,prev_ofs,weight);
	} else {
		depth = 1.0 - texture(_HeightmapTexture, ofs).r;
		float current_depth = 0.0;
		while(current_depth < depth) {
			ofs -= delta;
			depth = 1.0 - texture(_HeightmapTexture, ofs).r;
			current_depth += layer_depth;
		}
		vec2 prev_ofs = ofs + delta;
		float after_depth  = depth - current_depth;
		float before_depth = 0.0;
		before_depth = ( 1.0 - texture(_HeightmapTexture, prev_ofs).r  ) - current_depth + layer_depth;
		float weight = after_depth / (after_depth - before_depth);
		ofs = mix(ofs,prev_ofs,weight);
	}
	vec3 uvL = vec3(ofs,0.0);
	//uv.xy = ofs;
	return uvL;
}
"""

func _get_code(input_vars: Array, output_vars: Array, mode: int, type: int) -> String:
	var uvl = "vec3(UV, 0.0)"
	if input_vars[0]:
		uvl = input_vars[0]
	return "%s = ParallaxMapping_Simple(%s,%s,%s,%s,%s,%s,%s,VERTEX,NORMAL,TANGENT,BINORMAL);" % [output_vars[0], uvl, input_vars[1], input_vars[2], input_vars[6], input_vars[3], input_vars[4], input_vars[5]]

func _init():
	# Default values for the editor
	if not get_input_port_default_value(2):
		set_input_port_default_value(2, 0.05)
	if not get_input_port_default_value(3):
		set_input_port_default_value(3, 4)
	if not get_input_port_default_value(4):
		set_input_port_default_value(4, 16)
	if not get_input_port_default_value(5):
		set_input_port_default_value(5, Vector3(1.0, 1.0,0.0))
	if not get_input_port_default_value(6):
		set_input_port_default_value(6, false)