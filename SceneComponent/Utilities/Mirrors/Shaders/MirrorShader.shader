shader_type spatial; 
render_mode cull_back; //unshaded; //Really needed ?

uniform sampler2D Texture : hint_albedo;

uniform vec3 Angle;
uniform vec3 AngleTarget;
uniform vec4 Color : hint_color = vec4(0.0,0.0,1.0,1.0);
uniform bool MirrorEffect = true;
uniform float MirrorEffectDistanceMax = 100.0f;
uniform float MirrorEffectIntensity = 0.1f;

void fragment() {
	if( !MirrorEffect ) {
		ALBEDO = texture(Texture,UV).rgb * Color.rgb;
	} else {
		vec2 cUV = UV * 2.0;
		vec2 tex_size = vec2(1024.0*2.0,2560.0*2.0);
		vec2 tex_visibleSize = vec2(1024.0,2560.0);
		vec2 tex_center = vec2(0.25,0.25);//vec2(tex_size.x/2.0,tex_size.y/2.0);
		vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT*1.0,-BINORMAL*1.0,NORMAL));
		float view_dist = clamp(smoothstep(MirrorEffectDistanceMax/100.0, MirrorEffectDistanceMax, -VERTEX.z), 0.0, 1.0);
		vec3 mirror_normal = NORMAL;
		vec2 calcUV = vec2(acos(dot(view_dir,mirror_normal)) * mix(0.1,1.0,view_dist), acos(dot(view_dir,mirror_normal)) * mix(0.1,1.0,view_dist));
		cUV = cUV + tex_center;
		cUV = vec2(cUV.x + clamp(calcUV.x,-1.0,1.0), cUV.y + clamp(calcUV.y,-1.0,1.0));
		ALBEDO = texture(Texture,cUV).rgb * Color.rgb;
	}
	//ALBEDO = Color.rgb;
	METALLIC = 0.0f;
	SPECULAR = 1.0f;
	ROUGHNESS = 1.0f;
}