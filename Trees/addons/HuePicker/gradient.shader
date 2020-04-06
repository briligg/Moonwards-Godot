shader_type canvas_item;

uniform lowp vec4 color1 : hint_color;
uniform lowp vec4 color2 : hint_color;

void fragment(){
//	vec3 c = texture(SCREEN_TEXTURE,SCREEN_UV,0.0).rgb;
	COLOR = mix(color1,color2, UV.x);
}
