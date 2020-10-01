shader_type spatial; 
render_mode cull_back; //unshaded; //Really needed ?

uniform sampler2D Texture : hint_albedo;
uniform sampler2D TextureTester : hint_albedo;

uniform vec4 Color : hint_color = vec4(1.0,1.0,1.0,1.0);
uniform bool MirrorEffect = true;
uniform float MirrorEffectDistanceMax = 10.0f;
uniform float MirrorEffectIntensity = 0.1f;
uniform float VAngle = 0.0;
uniform float HAngle = 0.0;
uniform float _pr_perturb_scale = 1.0;
uniform vec4 _pr_viewport_rect = vec4(-1.0, -1.0, 2.0, 2.0);

vec3 GetWorldNormal( mat4 _Camera, vec3 _Normal ) {
	vec4 camx = _Camera[0];
	vec4 camy = _Camera[1];
	vec4 camz = _Camera[2];
	vec4 camw = _Camera[3];
	mat3 cam = mat3(camx.xyz, camy.xyz, camz.xyz);
	return _Normal * cam;
}

vec3 ProjectOnPlane( vec3 vec, vec3 normal )
{
    return vec - normal * dot( vec, normal );
}

vec3 ProjectOnPlaneComplex( vec3 v, vec3 n )
{
    vec3 r;
    r.x = n.y * n.y * v.x + n.z * n.z * v.x - n.x * n.y * v.y - n.x * n.z * v.z;
    r.y = n.x * n.x * v.y - n.x * n.y * v.x - n.y * n.z * v.z + n.z * n.z * v.y;
    r.z = n.x * n.x * v.z - n.x * n.z * v.x + n.y * n.y * v.z - n.y * n.z * v.y;
    return r / dot(n, n);
}


//vec4 GetCameraDistance( mat4 _Camera, vec3 _Normal ) {
	//ProjectOnPlane( vec3 vec, _Normal )

//}

vec3 _pr_normal_from_normalmap(vec3 normalmap, vec3 normal, vec3 tangent, vec3 binormal, float normaldepth) {
	normalmap.xy = normalmap.xy * 2.0 - 1.0;
	normalmap.z = sqrt(max(0.0, 1.0 - dot(normalmap.xy, normalmap.xy))); //always ignore Z, as it can be RG packed, Z may be pos/neg, etc.
	
	return normalize(mix(normal, tangent * normalmap.x + binormal * normalmap.y + normal * normalmap.z, normaldepth));
}

vec3 _pr_line_plane_intersect(vec3 line_origin, vec3 line_dir, vec3 plane_origin, vec3 plane_normal){
	return line_origin + line_dir * dot(plane_normal, plane_origin - line_origin) / dot(plane_normal, line_dir);
}

void fragment() {
	if( !MirrorEffect ) {
		ALBEDO = texture(Texture,UV).rgb * Color.rgb;
	} else {
		vec2 cUV = UV * 0.5;
		vec2 tex_size = vec2(1024.0*2.0,2560.0*2.0);
		vec2 tex_visibleSize = vec2(1024.0,2560.0);
		vec2 tex_center = vec2(0.25,0.25);//vec2(tex_size.x/2.0,tex_size.y/2.0);
		vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT*1.0,-BINORMAL*1.0,NORMAL)); //normalize(normalize(-VERTEX)*mat3(TANGENT*1.0,-BINORMAL*1.0,NORMAL)); GetWorldNormal(INV_CAMERA_MATRIX, NORMAL)
		vec3 view_dirH = vec3(view_dir.x, 0.0, view_dir.z);
		vec3 view_dirV = vec3(0.0, view_dir.y, view_dir.z);
		vec3 nH = normalize(view_dirH);
		vec3 lH = vec3(0.0, 0.0, 1.0);
		float ndotH = dot(nH, lH); //Horizontal lerp
		vec3 nV = normalize(view_dirV);
		vec3 lV = vec3(0.0, 0.0, 1.0);
		float ndotV = dot(nV, lV); // Vertical lerp

		float view_dist = clamp(smoothstep(MirrorEffectDistanceMax/1.0, MirrorEffectDistanceMax, -VERTEX.z), 0.0, 1.0);
		vec3 mirror_normal = GetWorldNormal(INV_CAMERA_MATRIX, NORMAL);
		vec2 calcUV = vec2(clamp(HAngle,-1.0,1.0),clamp(VAngle,-1.0,1.0)); //clamp(acos(dot(view_dir.xz,mirror_normal.xz)),0.0,1.0)
		//vec2 calcUV = vec2(clamp(acos(dot(view_dir,mirror_normal)) * mix(0.1,1.0,view_dist),0.0,1.0), clamp(acos(dot(view_dir,mirror_normal)) * mix(0.1,1.0,view_dist),0.0,1.0));
		//vec2 calcUV = vec2(1.0,0.0);
		cUV = cUV + tex_center;
		cUV = vec2(cUV.x + calcUV.x-0.5, cUV.y + calcUV.y-0.5);
		//ALBEDO = texture(TextureTester,cUV).rgb * Color.rgb;
		// (CAMERA_MATRIX * vec4(VERTEX, 1.0)).x Get camera
		
		vec3 _pr_ray_origin = CAMERA_MATRIX[3].xyz;
		vec3 _pr_plane_origin = WORLD_MATRIX[3].xyz;
		vec3 _pr_plane_normal = WORLD_MATRIX[2].xyz;
		vec3 _pr_final_normal = _pr_normal_from_normalmap(NORMALMAP, NORMAL, TANGENT, BINORMAL, NORMALMAP_DEPTH);
		
		vec4 _pr_point_on_plane = CAMERA_MATRIX * vec4(VERTEX, 1.0);
		//_pr_point_on_plane.xyz += reflect(mat3(CAMERA_MATRIX) * reflect(-VIEW, _pr_final_normal) * _pr_perturb_scale, _pr_plane_normal);
		_pr_point_on_plane.xyz = _pr_line_plane_intersect(_pr_ray_origin, _pr_point_on_plane.xyz - _pr_ray_origin, _pr_plane_origin, _pr_plane_normal);
		
		vec4 _pr_model_pos = inverse(WORLD_MATRIX) * _pr_point_on_plane;
		vec2 _pr_uv = (vec2(_pr_model_pos.x, -_pr_model_pos.y) - _pr_viewport_rect.xy) / _pr_viewport_rect.zw;
		ALBEDO = texture(TextureTester,_pr_uv).rgb * Color.rgb;
		
		//float a = GetCameraDistance( CAMERA_MATRIX[3].xyz, WORLD_MATRIX[2].xyz ).x;//dot(NORMAL, VIEW);
		//ALBEDO = mix(vec3(1.0,0.0,0.0),vec3(0.0,1.0,0.0),a); //clamp(clamp((CAMERA_MATRIX * vec4(VERTEX, 1.0)).x,0.0,1.0)*1.0,0.0,1.0));
		
	}
	//ALBEDO = Color.rgb;
	METALLIC = 0.0f;
	SPECULAR = 1.0f;
	ROUGHNESS = 1.0f;
}