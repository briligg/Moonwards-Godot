shader_type spatial; 
render_mode cull_back; //unshaded; //Really needed ?

uniform sampler2D Texture : hint_albedo;

uniform vec3 Angle;
uniform vec3 AngleTarget;
uniform vec4 Color : hint_color = vec4(0.0,0.0,1.0,1.0);

void fragment() {
	ALBEDO = texture(Texture,UV).rgb * Color.rgb;
	//ALBEDO = Color.rgb;
	METALLIC = 0.0f;
	SPECULAR = 1.0f;
	ROUGHNESS = 1.0f;
}