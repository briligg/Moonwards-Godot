shader_type spatial;

uniform vec3 Angle;
uniform vec3 AngleTarget;
uniform vec4 Color: hint_color;

void fragment() {
	METALLIC = 1.0f;
	SPECULAR = 1.0f;
	ROUGHNESS = 0.0f;
}