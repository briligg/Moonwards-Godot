shader_type canvas_item;

void fragment() {
	
	vec4 bg = textureLod(SCREEN_TEXTURE,SCREEN_UV,0.0);
	vec4 fg = textureLod(TEXTURE, UV, 0.0);
	
	//old XOR conversion
//	ivec3 b = ivec3(int(bg.r * 255.0), int(bg.g * 255.0), int(bg.b * 255.0));
//	ivec3 a = ivec3(int(fg.r * 255.0), int(fg.g * 255.0), int(fg.b * 255.0));
//	ivec3 xor = b ^ a;
//	vec4 output = vec4(float(xor.r)/255.0, float(xor.g)/255.0, float(xor.b)/255.0, fg.a);

	//new Difference blend
	vec4 output = vec4(abs(fg.r - bg.r), abs(fg.g - bg.g), abs(fg.b - bg.b), fg.a);
	
	COLOR = output;
	
	}