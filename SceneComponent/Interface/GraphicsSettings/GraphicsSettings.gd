extends Control


const QUALITY = "rendering/quality/"

var list : Array = ProjectSettings.get_property_list()


func _high_selected() -> void :
	_pj_set(QUALITY + "intended_usage/framebuffer_allocation", 2)
	
	var text : String = QUALITY + "filters/"
	_pj_set(text + "anisotropic_filter_level", 16)
	_pj_set(text+"use_nearest_mipmap_filter", true)
	_pj_set(text+"msaa", 1)
	
	text = QUALITY+"directional_shadow/"
	_pj_set(text+"size", 4096)
	
	text = QUALITY+"shadow_atlas/quadrant_"
	_pj_set(text+"0_subdiv", 1)
	_pj_set(text+"1_subdiv", 2)
	_pj_set(text+"2_subdiv", 3)
	_pj_set(text+"3_subdiv", 4)
	text = QUALITY+"shadow_atlas/"
	_pj_set(text+"size", 4096)
	
	text = QUALITY + "shadows/"
	_pj_set(text+"filter_mode", 2)
	
	text = QUALITY + "reflections/"
	_pj_set(text+"texture_array_reflections", true)
	_pj_set(text+"high_quality_ggx", true)
	_pj_set(text+"irradiance_max_size", 256)
	_pj_set(text+"atlas_size", 2048)
	_pj_set(text+"atlas_subdiv", 8)
	
	text = QUALITY+"shading/"
	_pj_set(text+"force_vertex_shading", false)
	_pj_set(text+"force_lambert_over_burley", false)
	
	text = QUALITY+"depth_prepass/"
	_pj_set(text+"enable", true)
	
	text = QUALITY+"subsurface_scattering/"
	_pj_set(text+"quality", 1)
	_pj_set(text+"scale", 1)
	
	text = QUALITY+"depth/"
	_pj_set(text+"hdr", true)

func _ready() -> void :
	var graphics = $LodTransition2/GraphicsOptions
	graphics.connect("low_selected", self, "_low_selected")
	graphics.connect("high_selected", self, "_high_selected")

#Set the graphics settings as low as possible.
func _low_selected() -> void :
	_pj_set(QUALITY + "intended_usage/framebuffer_allocation", 3)
	
	var text : String = QUALITY + "filters/"
	_pj_set(text + "anisotropic_filter_level", 1)
	_pj_set(text+"use_nearest_mipmap_filter", false)
	_pj_set(text+"msaa", 0)
	
	text = QUALITY+"directional_shadow/"
	_pj_set(text+"size", 256)
	
	text = QUALITY+"shadow_atlas/quadrant_"
	_pj_set(text+"0_subdiv", 0)
	_pj_set(text+"1_subdiv", 0)
	_pj_set(text+"2_subdiv", 0)
	_pj_set(text+"3_subdiv", 0)
	text = QUALITY+"shadow_atlas/"
	_pj_set(text+"size", 256)
	
	text = QUALITY + "shadows/"
	_pj_set(text+"filter_mode", 0)
	
	text = QUALITY + "reflections/"
	_pj_set(text+"texture_array_reflections", false)
	_pj_set(text+"high_quality_ggx", false)
	_pj_set(text+"irradiance_max_size", 32)
	_pj_set(text+"atlas_size", 0)
	_pj_set(text+"atlas_subdiv", 0)
	
	text = QUALITY+"shading/"
	_pj_set(text+"force_vertex_shading", true)
	_pj_set(text+"force_lambert_over_burley", true)
	
	text = QUALITY+"depth_prepass/"
	_pj_set(text+"enable", false)
	
	text = QUALITY+"subsurface_scattering/"
	_pj_set(text+"quality", 0)
	_pj_set(text+"scale", 0)
	
	text = QUALITY+"depth/"
	_pj_set(text+"hdr", false)
	

#Helper function for setting ProjectSettings with less typing.
func _pj_set(property : String, value) -> void :
	assert(property in ProjectSettings)
	ProjectSettings.set(property, value)
