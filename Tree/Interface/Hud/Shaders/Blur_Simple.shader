shader_type canvas_item;

uniform float Amount: hint_range(0.0, 10.0);

void fragment() {
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, Amount).rgb;
}