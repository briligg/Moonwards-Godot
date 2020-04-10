shader_type canvas_item;
uniform float hue : hint_range(0.0,1.0);

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
//	vec3 c = texture(SCREEN_TEXTURE,SCREEN_UV,0.0).rgb;	
//	ivec2 size = textureSize(SCREEN_TEXTURE,0);


	float gamut = 1.0 - (UV.x) / 2.0;   //range of luminance values to express approaches 0 as saturation reaches 1
//	vec3 rgb = hsv2rgb(vec3(hue, SCREEN_UV.x,  1.0 - mix(0.0, gamut, SCREEN_UV.y) - (1.0-gamut)  ));
	vec3 rgb = hsv2rgb(vec3(hue, UV.x, 1.0-UV.y));
	COLOR.rgb = rgb;
	
}