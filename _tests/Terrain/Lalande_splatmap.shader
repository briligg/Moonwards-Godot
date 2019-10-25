shader_type spatial;
render_mode blend_mix,depth_draw_opaque,world_vertex_coords;
uniform sampler2D splatmap : hint_white;
uniform sampler2D splatmap_2 : hint_white;
uniform sampler2D global_normal : hint_normal;
uniform sampler2D global_albedo : hint_albedo;
uniform bool show_splatmap;
uniform bool double_filter;
uniform float double_filter_blend;
uniform bool detail_enabled;

uniform sampler2D texture0 : hint_albedo;
uniform sampler2D normal_tex0 : hint_normal;
uniform float normal_depth0 : hint_range(-16,16);

uniform sampler2D texture1 : hint_albedo;
uniform sampler2D normal_tex1 : hint_normal;
uniform float normal_depth1 : hint_range(-16,16);

uniform sampler2D texture2 : hint_albedo;
uniform sampler2D normal_tex2 : hint_normal;
uniform float normal_depth2 : hint_range(-16,16);

uniform sampler2D texture3 : hint_albedo;
uniform sampler2D normal_tex3 : hint_normal;
uniform float normal_depth3 : hint_range(-16,16);

uniform sampler2D texture4 : hint_albedo;
uniform sampler2D normal_tex4 : hint_normal;
uniform float normal_depth4 : hint_range(-16,16);

uniform sampler2D texture5 : hint_albedo;
uniform sampler2D normal_tex5 : hint_normal;
uniform float normal_depth5 : hint_range(-16,16);


uniform sampler2D detail_normal : hint_normal;
uniform float detail_normal_depht : hint_range(-1,1);
uniform float normal_depth : hint_range(-16,16);

uniform float specular;
uniform float metallic;
uniform float subsurface_scattering_strength : hint_range(0,1);

varying vec3 uv1_triplanar_pos;
varying vec3 uv2_triplanar_pos;
varying vec3 uv3_triplanar_pos;
varying vec3 uv4_triplanar_pos;
varying vec3 uv5_triplanar_pos;
varying vec3 uv6_triplanar_pos;
uniform float uv1_blend_sharpness = 1;
varying vec3 uv1_power_normal;
uniform float uv2_blend_sharpness = 1;
varying vec3 uv2_power_normal;
uniform float uv3_blend_sharpness = 1;
varying vec3 uv3_power_normal;
uniform float uv4_blend_sharpness = 1;
varying vec3 uv4_power_normal;
uniform float uv5_blend_sharpness = 1;
varying vec3 uv5_power_normal;
uniform float uv6_blend_sharpness = 1;
varying vec3 uv6_power_normal;
uniform float uv1_scale = 0.1;
uniform vec3 uv1_offset;
uniform float uv2_scale = 0.1;
uniform vec3 uv2_offset;
uniform float uv3_scale = 0.1;
uniform vec3 uv3_offset;
uniform float uv4_scale = 0.1;
uniform vec3 uv4_offset;
uniform float uv5_scale = 0.1;
uniform vec3 uv5_offset;
uniform float uv6_scale = 0.1;
uniform vec3 uv6_offset;

uniform float blend = 0;
void TriangleGrid ( vec2 uv , out float w1 , out float w2 , out float w3 , out vec2 vertex1 , out vec2 vertex2 , out vec2 vertex3 )
	{
	// Scaling of the input
	uv *= 3.464; // 2 * sqrt (3)
	// Skew input space into simplex triangle grid
	mat2 gridToSkewedGrid = mat2 (vec2(1.0 , 0.0) , vec2(-0.57735027 , 1.15470054)) ;
	vec2 skewedCoord = gridToSkewedGrid * uv ;
	// Compute local triangle vertex IDs and local barycentric coordinates
	ivec2 baseId = ivec2 ( floor ( skewedCoord ));
	vec3 temp = vec3 ( fract ( skewedCoord ) , 0) ;
	temp .z = 1.0 - temp . x - temp .y;
	if ( temp . z > 0.0)
	{
		w1 = temp .z;
		w2 = temp .y;
		w3 = temp .x;
		vertex1 = vec2(float(baseId.x), float(baseId.y)) ;
		vertex2 = vertex1 + vec2 (0 , 1) ;
		vertex3 = vertex1 + vec2 (1 , 0) ;
	}
	else
	{
		w1 = - temp .z ;
		w2 = 1.0 - temp .y;
		w3 = 1.0 - temp .x;
		vertex1 = vec2(float(baseId.x), float(baseId.y)) + vec2 (1 , 1) ;
		vertex2 = vec2(float(baseId.x), float(baseId.y)) + vec2 (1 , 0) ;
		vertex3 = vec2(float(baseId.x), float(baseId.y)) + vec2 (0 , 1) ;
	}
}

vec2 hash2D2D (vec2 s)
{
    //magic numbers
    return fract(sin(mod(vec2(dot(s, vec2(127.1,311.7)), dot(s, vec2(269.5,183.3))), 3.14159))*43758.5453);
}

vec3 ProceduralTilingAndBlending (sampler2D input, vec2 uv, vec2 duvdx, vec2 duvdy )
{
	// Get triangle info
	float w1 , w2 , w3 ;
	vec2 vertex1 , vertex2 , vertex3 ;
	TriangleGrid (uv , w1 , w2 , w3 , vertex1 , vertex2 , vertex3 );
	// Assign random offset to each triangle vertex
	vec2 uv1 = uv + hash2D2D ( vertex1 );
	vec2 uv2 = uv + hash2D2D ( vertex2 );
	vec2 uv3 = uv + hash2D2D ( vertex3 );
	
	// Fetch input
	vec3 I1 = textureGrad ( input , uv1 , duvdx , duvdy ). rgb ;
	vec3 I2 = textureGrad ( input , uv2 , duvdx , duvdy ). rgb ;
	vec3 I3 = textureGrad ( input , uv3 , duvdx , duvdy ). rgb ;
	// Variance - preserving blending
	vec3 G;
	vec3 I = w1 * I1 + w2 * I2 + w3 * I3 ;
	G = I - vec3 (0.5) ;
	G = G * inversesqrt ( w1 * w1 + w2 * w2 + w3 * w3 ) ;
	G = G + vec3 (0.5) ;
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, G));
	G = mix(G, gray, 0.5);
	
	return mix(I,G,0.4);
}
 
//stochastic sampling
vec4 textureStochastic(sampler2D tex, vec2 uv, vec2 dx,  vec2 dy)
{
    //triangle vertices and blend weights
    //BW_vx[0...2].xyz = triangle verts
    //BW_vx[3].xy = blend weights (z is unused)
    mat4 BW_vx;
 
    //uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)
    vec2 newUV = (mat2(vec2(1.0 , 0.0) , vec2(-0.57735027 , 1.15470054))* uv * 3.464);
 
    //vertex IDs and barycentric coords
    vec2 vxID = vec2 (floor(newUV));
    vec3 fracted = vec3 (fract(newUV), 0);
    fracted.z = 1.0-fracted.x-fracted.y;
 
    BW_vx = ((fracted.z>0.0) ?
        mat4(vec4(vxID, 0,0), vec4(vxID + vec2(0, 1), 0,0), vec4(vxID + vec2(1, 0), 0,0), vec4(fracted,0)) :
        mat4(vec4(vxID + vec2 (1, 1), 0,0), vec4(vxID + vec2 (1, 0), 0,0), vec4(vxID + vec2 (0, 1), 0,0), vec4(-fracted.z, 1.0-fracted.y, 1.0-fracted.x,0)));
 
    //calculate derivatives to avoid triangular grid artifacts
   

    //blend samples with calculated weights
    return (textureGrad(tex, uv + hash2D2D(BW_vx[0].xy), dx, dy) * BW_vx[3].x +
	       textureGrad(tex, uv + hash2D2D(BW_vx[1].xy), dx, dy) * BW_vx[3].y +
           textureGrad(tex, uv + hash2D2D(BW_vx[2].xy), dx, dy) * BW_vx[3].z);
	
}
vec4 STexComplexB(sampler2D input, vec2 uv){
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	vec4 tex = vec4(ProceduralTilingAndBlending(input, uv, dx, dy),1);
	if (double_filter){
		tex = mix(tex, textureStochastic(input, uv, dx, dy), double_filter_blend);
	}
	return tex;
}

void vertex() {
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,-1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,-1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	uv2_power_normal=pow(abs(NORMAL), vec3(uv2_blend_sharpness));
	uv2_power_normal/=dot(uv2_power_normal,vec3(1.0));
	uv2_triplanar_pos = VERTEX * uv2_scale + uv2_offset;
	uv2_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	uv3_power_normal=pow(abs(NORMAL),vec3(uv3_blend_sharpness));
	uv3_power_normal/=dot(uv3_power_normal,vec3(1.0));
	uv3_triplanar_pos = VERTEX * uv3_scale + uv3_offset;
	uv3_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	uv4_power_normal=pow(abs(NORMAL),vec3(uv4_blend_sharpness));
	uv4_power_normal/=dot(uv4_power_normal,vec3(1.0));
	uv4_triplanar_pos = VERTEX * uv4_scale + uv4_offset;
	uv4_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	uv5_power_normal=pow(abs(NORMAL),vec3(uv5_blend_sharpness));
	uv5_power_normal/=dot(uv5_power_normal,vec3(1.0));
	uv5_triplanar_pos = VERTEX * uv5_scale + uv5_offset;
	uv5_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	uv6_power_normal=pow(abs(NORMAL),vec3(uv6_blend_sharpness));
	uv6_power_normal/=dot(uv6_power_normal,vec3(1.0));
	uv6_triplanar_pos = VERTEX * uv6_scale + uv6_offset;
	uv6_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= STexComplexB(p_sampler,p_triplanar_pos.xy) * 0.5*p_weights.z;
	samp+= STexComplexB(p_sampler,p_triplanar_pos.xz) * 0.5 * p_weights.y;
	samp+= STexComplexB(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	vec3 color0;
	vec3 normal0;
	vec3 color1;
	vec3 normal1;
	vec3 color2;
	vec3 normal2;
	vec3 color3;
	vec3 normal3;
	vec3 color4;
	vec3 normal4;
	vec3 color5;
	vec3 normal5;
	vec3 normal;
	vec3 albedo;
	vec3 splatmapcolor;
	vec3 splatmapcolor_2;
	vec4 globalnormal;
	globalnormal = texture(global_normal, UV);
	
	vec3 mixed_splatcolor = mix(texture(splatmap, UV).rgb, texture(splatmap_2, UV).rgb, (greaterThan(texture(splatmap_2, UV).rgb, vec3(0.08))));
	splatmapcolor = max(vec3(0.0), mixed_splatcolor - texture(splatmap_2, UV).rgb);
	splatmapcolor_2 = max(vec3(0.0), mixed_splatcolor - texture(splatmap, UV).rgb);

	color0 = mix(vec3(0), triplanar_texture(texture0, uv1_power_normal, uv1_triplanar_pos).rgb, splatmapcolor.r);
	normal0 = mix(vec3(0),triplanar_texture(normal_tex0, uv1_power_normal, uv1_triplanar_pos).rgb , splatmapcolor.r);

	color1 = mix(vec3(0), triplanar_texture(texture1,uv2_power_normal, uv2_triplanar_pos).rgb, splatmapcolor.g);
	normal1 = mix(vec3(0),triplanar_texture(normal_tex2, uv2_power_normal, uv2_triplanar_pos).rgb , splatmapcolor.g);

	color2 = mix(vec3(0), triplanar_texture(texture2, uv3_power_normal, uv3_triplanar_pos).rgb , splatmapcolor.b);
	normal2 = mix(vec3(0),triplanar_texture(normal_tex2, uv3_power_normal, uv3_triplanar_pos).rgb , splatmapcolor.b);
	
	color3 = mix(vec3(0), triplanar_texture(texture3, uv4_power_normal, uv4_triplanar_pos).rgb , splatmapcolor_2.r);
	normal3 = mix(vec3(0),triplanar_texture(normal_tex3, uv4_power_normal, uv4_triplanar_pos).rgb , splatmapcolor_2.r);
	
	color4 = mix(vec3(0), triplanar_texture(texture4, uv5_power_normal, uv5_triplanar_pos).rgb , splatmapcolor_2.g);
	normal4 = mix(vec3(0),triplanar_texture(normal_tex4, uv5_power_normal, uv5_triplanar_pos).rgb , splatmapcolor_2.g);
	
	color5 = mix(vec3(0), triplanar_texture(texture5, uv6_power_normal, uv6_triplanar_pos).rgb , splatmapcolor_2.b);
	normal5 = mix(vec3(0),triplanar_texture(normal_tex5, uv6_power_normal, uv6_triplanar_pos).rgb , splatmapcolor_2.b);
	
	float splatmap_weigt = splatmapcolor.r + splatmapcolor.g + splatmapcolor.b + splatmapcolor_2.r + splatmapcolor_2.g + splatmapcolor_2.b;
	ALBEDO = mix(texture(global_albedo,UV).rgb, (color0 + color1 + color2 + color3 + color4 + color5), min(1.0, splatmap_weigt));
	
	normal = texture(global_normal, UV).rgb * (vec3(1.0) - (splatmapcolor.r));
	if (detail_enabled) {
		normal = (texture(global_normal,UV).rgb+detail_normal_depht*mix(vec3(0), triplanar_texture(detail_normal, uv3_power_normal, uv3_triplanar_pos*10.0).rgb , (vec3(1.0) - (splatmapcolor.r))));
	}
	normal = normal * (vec3(1.0) - (splatmapcolor.g));
	normal = normal * (vec3(1.0) - (splatmapcolor.b));
	
	normal = normal * (vec3(1.0) - (splatmapcolor_2.r));
	normal = normal * (vec3(1.0) - (splatmapcolor_2.g));
	normal = normal * (vec3(1.0) - (splatmapcolor_2.b));
	
	SPECULAR = specular;
	METALLIC = metallic;
	ROUGHNESS = 1.0;

	NORMALMAP = normalize(normal_depth*normal + normal_depth0*normal0 + normal_depth1*normal1 + normal_depth2*normal2 + normal_depth3*normal3 + normal_depth4*normal4 + normal_depth5*normal5);
	NORMALMAP = (NORMALMAP + globalnormal.rgb)/length(NORMALMAP+globalnormal.rgb);
	//ALBEDO = triplanar_texture(texture1, uv1_power_normal, uv1_triplanar_pos).rgb;
	if(show_splatmap){
		ALBEDO = (splatmapcolor + splatmapcolor_2).rgb;
	}
	
	
	SSS_STRENGTH=subsurface_scattering_strength;
	//FLAG!
}
