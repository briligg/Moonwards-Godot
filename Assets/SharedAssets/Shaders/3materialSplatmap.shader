shader_type spatial;

uniform sampler2D splatmap;
uniform sampler2D base;
uniform sampler2D accent1;
uniform sampler2D accent2;

uniform float baseres = 1;
uniform float accent1res = 1;
uniform float accent2res = 1;

void fragment() {
	vec3 basecolor;
	vec3 accent1color;
	vec3 accent2color;
	vec3 splatmapcolor;
	
	splatmapcolor = texture(splatmap, UV).rgb;
	
	basecolor = texture(base, UV * baseres).rgb * splatmapcolor.r;
	accent1color = texture(accent1, UV * accent1res).rgb * splatmapcolor.g;
	accent2color = texture(accent2, UV * accent2res).rgb * splatmapcolor.b;
	
	ALBEDO = basecolor + accent1color + accent2color;
	}