shader_type canvas_item;

uniform float Amount: hint_range(0.0, 10.0);
uniform vec4 Color: hint_color = vec4(1.0,1.0,1.0,0.5);

void fragment() {
	vec3 color = Color.rgb * Color.a;
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, Amount).rgb * color;
}