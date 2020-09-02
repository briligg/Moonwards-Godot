shader_type spatial;
render_mode blend_mix, depth_draw_always;

// Waves color and heigh
uniform sampler2D Heightmap_A : hint_black_albedo;

// Waves details
uniform sampler2D Detailmap : hint_albedo;
// Refraction normalmap and world normal map
uniform sampler2D DetailNormalmap : hint_normal;

//Depth
uniform float DepthFactor = 0.05;
uniform float DepthAlpha = 0.05; // Set this to 0
uniform float DepthRough = 0.05;
uniform float DepthAlphaPrePass = 0.1;

//Surface waves
uniform float Refraction = 0.05;
uniform vec2 RoughnessMinMax = vec2(0.0,0.3);
uniform vec2 MetallicMinMax = vec2(0.1,0.5);
uniform vec2 SpecularMinMax = vec2(0.6,1.0);
// Normal map effect
uniform float NormalDepth = 1.0;
//uniform float WavesSpeed = 0.5;
// Waves scale in axis
uniform vec2 WavesScale = vec2(0.1,0.75);
// Waves speed in axis
uniform vec2 WavesSpeed = vec2(0.1,0.1);
// Waves general speed
uniform float WavesSpeedG = 0.1;
// Waves timer mod of speed (Set to default value)
uniform float WavesSpeedMod = 0.1;
// Waves intensity 
uniform float WavesIntensity = 1.0;
uniform float WavesIntensityMod = 1.0;
// Waves intensity elevation range
uniform vec2 WavesIntensityMinMax = vec2(-1.0,1.0);
// Waves primary color
uniform vec4 WavesColor : hint_color;
// Waves detail color
uniform vec4 WavesColorAlt : hint_color;
//uniform vec4 WavesColorSide : hint_color;

// Surface details
// Detail waves scale in axis
uniform vec2 DetailScale = vec2(0.1,0.75);
// Detail waves speed
uniform vec2 DetailSpeed = vec2(0.1,0.1);
// Detail speed global
uniform float DetailSpeedG = 0.1;
// Detail intensity
uniform float DetailIntensity = 1.0;
uniform float DetailNormalIntensity = 1.0;

void vertex() {
	// Main waves UV scales
	vec2 UVScale = vec2(UV.x * WavesScale.x, UV.y * WavesScale.y);
	vec2 UVScaleSec = vec2(UVScale.x + TIME * (WavesSpeed.x * WavesSpeedG), UVScale.y + TIME * (WavesSpeed.y * WavesSpeedG));
	// Get waves intensity and clamp it
	float lerp = clamp(texture(Heightmap_A,UVScaleSec).g * WavesIntensity, 0.0, 1.0);
	
	// Secondary Wave layer
	UVScaleSec = vec2(UVScale.x + TIME * ((WavesSpeed.x * WavesSpeedG) * -1.0), UVScale.y + TIME * ((WavesSpeed.y * WavesSpeedG) * -1.0));
	lerp = clamp(lerp + clamp(texture(Heightmap_A,UVScaleSec).g * WavesIntensity, 0.0, 1.0), 0.0, 1.0);
	// Combine waves
	lerp = lerp * ((sin(TIME*WavesSpeedMod) * 0.5 + (0.5 + 0.3)) * WavesIntensityMod);
	lerp = mix(WavesIntensityMinMax.x, WavesIntensityMinMax.y, lerp);
	
	if( COLOR.r > 0.9) {
		VERTEX.y = VERTEX.y + lerp;
	}
	NORMAL = cross(TANGENT, BINORMAL);
}

vec3 GetLocalWorldDepth( sampler2D _Depth, vec2 _ScreenUV, mat4 _InvProjection ) {
	float depth = textureLod(_Depth, _ScreenUV.xy, 0.0).r;
	vec4 worldPos = vec4(_ScreenUV.xy * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0) * _InvProjection;
	return worldPos.xyz / worldPos.w;
}

vec3 NormalMult(vec3 _Normal, float _Amount){
	return vec3(_Normal.x * _Amount, _Normal.y * _Amount, 1.0);
}

void fragment(){
	//Primary wave
	vec2 UVScale = vec2(UV.x * WavesScale.x, UV.y * WavesScale.y);
	vec2 UVScaleSec = vec2(UVScale.x + TIME * (WavesSpeed.x * WavesSpeedG), UVScale.y + TIME * (WavesSpeed.y * WavesSpeedG));
	float lerp = texture(Heightmap_A,UVScaleSec).g;
	// Secondary Wave layer
	UVScaleSec = vec2(UVScale.x + TIME * ((WavesSpeed.x * WavesSpeedG) * -1.0), UVScale.y + TIME * ((WavesSpeed.y * WavesSpeedG) * -1.0));
	// Combine waves
	lerp = clamp(lerp + texture(Heightmap_A,UVScaleSec).g, 0.0, 1.0);
	
	// Detail
	// Main wave
	vec2 dUVScale = vec2(UV.x * DetailScale.x, UV.y * DetailScale.y);
	vec2 dUVScaleN = vec2(UV.x * DetailScale.x * 1.0, UV.y * DetailScale.y * -1.0);
	vec2 dUVScaleCalc = vec2(dUVScale.x + TIME * (DetailSpeed.x * DetailSpeedG), dUVScale.y + TIME * (DetailSpeed.y * DetailSpeedG));
	vec3 dLerp = texture(Detailmap,dUVScaleCalc).rgb;
	// Reverse wave
	vec3 dNLerp = NormalMult(texture(DetailNormalmap,dUVScaleCalc).rgb,DetailNormalIntensity);
	dUVScaleCalc = vec2(dUVScaleN.x + TIME * ((DetailSpeed.x * DetailSpeedG) * -1.0), dUVScaleN.y + TIME * ((DetailSpeed.y * DetailSpeedG) * -1.0));
	dLerp = clamp(dLerp * texture(Detailmap,dUVScaleCalc).rgb, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0));
	dNLerp = clamp(dNLerp * NormalMult(texture(DetailNormalmap,dUVScaleCalc).rgb,DetailNormalIntensity), vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0));
	dNLerp = vec3(dNLerp.x,dNLerp.y, 1.0 );

	vec3 albedo = mix(WavesColor,WavesColorAlt,lerp).rgb;
	ALBEDO = vec3(albedo.x,albedo.y,albedo.z);
	//ALPHA = DepthAlphaPrePass;
	
	// Depth buffer get
	float wDepth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	wDepth = (wDepth * 2.0) - 1.0;
	wDepth = -PROJECTION_MATRIX[3][2] / (wDepth + PROJECTION_MATRIX[2][2]);
	wDepth = -(wDepth + -VERTEX.z);
	wDepth = exp(-wDepth * DepthFactor);
	
	if (ALBEDO.r > DepthAlpha && ALBEDO.g > DepthAlpha && ALBEDO.b > DepthAlpha) {
		ALPHA = DepthAlphaPrePass;
	} else {
		ALPHA = clamp(1.0 - wDepth, 0.0, 1.0);
	}
	
	vec2 dsUVScale = vec2(UV2.x * DetailScale.x, UV2.y * DetailScale.y);
	vec2 dsUVScaleCalc = vec2(dsUVScale.x + TIME * (DetailSpeed.x * DetailSpeedG), dsUVScale.y + TIME * (DetailSpeed.y * DetailSpeedG));
	vec3 dsLerp = texture(Detailmap,dsUVScaleCalc).rgb;
	dsLerp = clamp(dsLerp * texture(Detailmap,dsUVScaleCalc).rgb, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0));
	
	NORMALMAP += ((dNLerp* DetailIntensity) * lerp);
	if( COLOR.r > 0.99) {
		NORMALMAP_DEPTH = NormalDepth;
	} else {	
		NORMALMAP_DEPTH = NORMALMAP_DEPTH;	
	}
	
	// Refraction
	vec3 ref_normal = normalize( mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH) );
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * lerp * Refraction; // dot(texture(texture_refraction,UVScale),
	float ref_amount = 1.0 - ALPHA;
	if( COLOR.r > 0.99) {
		EMISSION += (dLerp * DetailIntensity) * lerp;
		EMISSION += albedo * 0.05;
		EMISSION += (textureLod(SCREEN_TEXTURE,ref_ofs,ROUGHNESS * DepthRough).rgb * ref_amount);// + ((dLerp * DetailIntensity) * lerp);
	} else {
		EMISSION += ((dLerp * DetailIntensity) + (dsLerp * DetailIntensity)) * lerp;
		EMISSION += albedo * 0.05;
		EMISSION += (textureLod(SCREEN_TEXTURE,ref_ofs,ROUGHNESS * DepthRough).rgb * ref_amount);
	}
	
	METALLIC = mix( MetallicMinMax.x, MetallicMinMax.y, lerp );
	ROUGHNESS = mix( RoughnessMinMax.x, RoughnessMinMax.y, lerp );
	SPECULAR = mix( SpecularMinMax.x, SpecularMinMax.y, lerp );
	//ALPHA = clamp(mix(WavesColor,WavesColorAlt,lerp).a * (wDepth * DepthAlpha), 0.0, 1.0);
	
	//ALBEDO = (albedo - ref_amount);//vec3(wDepth,wDepth,wDepth); //(albedo - ref_amount);// + (dLerp * DetailIntensity);
	//ALBEDO = albedo * ref_amount;
	ALBEDO *= ALPHA;
	ALPHA = 1.0;
}