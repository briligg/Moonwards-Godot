shader_type canvas_item;
uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;

void fragment() {
	vec4 c = texture(SCREEN_TEXTURE,SCREEN_UV,0.0);  //get pixel
	
	//mask me.
	if(c == vec4(1.0,0.0,1.0,1.0)) {
		COLOR = mix(color1, color2, UV.x);
	} else {
		COLOR.rgba = c
	}
}