shader_type spatial; 
render_mode cull_back; //unshaded; //Really needed ?

uniform sampler2D Texture : hint_albedo;
uniform sampler2D TextureTester : hint_albedo;

uniform vec3 Angle;
uniform vec3 AngleTarget;
uniform vec4 Color : hint_color = vec4(1.0,1.0,1.0,1.0);
uniform bool MirrorEffect = true;
uniform float MirrorEffectDistanceMax = 10.0f;
uniform float MirrorEffectIntensity = 0.1f;


vec3 GetWorldNormal( mat4 _Camera, vec3 _Normal ) {
	vec4 camx = _Camera[0];
	vec4 camy = _Camera[1];
	vec4 camz = _Camera[2];
	vec4 camw = _Camera[3];
	mat3 cam = mat3(camx.xyz, camy.xyz, camz.xyz);
	return _Normal * cam;
}

void fragment() {
	if( !MirrorEffect ) {
		ALBEDO = texture(Texture,UV).rgb * Color.rgb;
	} else {
		vec2 cUV = UV * 0.5;
		vec2 tex_size = vec2(1024.0*2.0,2560.0*2.0);
		vec2 tex_visibleSize = vec2(1024.0,2560.0);
		vec2 tex_center = vec2(0.25,0.25);//vec2(tex_size.x/2.0,tex_size.y/2.0);
		vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT*1.0,-BINORMAL*1.0,NORMAL));
		float view_dist = clamp(smoothstep(MirrorEffectDistanceMax/100.0, MirrorEffectDistanceMax, -VERTEX.z), 0.0, 1.0);
		vec3 mirror_normal = GetWorldNormal( INV_CAMERA_MATRIX, NORMAL );
		vec2 calcUV = vec2(clamp(acos(dot(view_dir,mirror_normal)) * mix(0.1,1.0,view_dist),0.0,1.0), clamp(acos(dot(view_dir,mirror_normal)) * mix(0.1,1.0,view_dist),0.0,1.0));
		//vec2 calcUV = vec2(1.0,0.0);
		cUV = cUV + tex_center;
		cUV = vec2(cUV.x + calcUV.x-0.5, cUV.y + calcUV.y-0.5);
		ALBEDO = texture(TextureTester,cUV).rgb * Color.rgb;
	}
	//ALBEDO = Color.rgb;
	METALLIC = 0.0f;
	SPECULAR = 1.0f;
	ROUGHNESS = 1.0f;
}