# TODO: Use class_name so this can be called without instancing
func HSVtoRGB (hue : float, saturation : float, luminance: float) -> Color:
	var r : float = float(luminance)
	var g : float = float(luminance)
	var b : float = float(luminance)
	
	var v : float = 0.0

	if luminance <= 0.5:
		v = luminance * (1.0 + saturation)
	else:
		v = luminance + saturation - luminance * saturation

	if v > 0:
		var m = luminance + luminance - v
		var sv = (v - m) / v
		hue *= 6
		var sextant = int(hue)
		var fract = float(hue) - float(sextant)
		var vsf = v * sv * fract
		var mid1 = m + vsf
		var mid2 = v - vsf
		
		match sextant:
			0:
				r = v
				g = mid1
				b = m
			1:
				r = mid2
				g = v
				b = m
			2:
				r = m
				g = v
				b = mid1
			3:
				r = m
				g = mid2
				b = v
			4:
				r = mid1
				g = m
				b = v
			5:
				r = v
				g = m
				b = mid2
	return Color(r,g,b)
