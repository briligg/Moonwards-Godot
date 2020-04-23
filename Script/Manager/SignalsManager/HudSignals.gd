extends Reference
class_name HudSignals

### Until we or godot implements proper class_name handling
const name = "Hud"

# Define the signal's string name.
const EXTRA_INFO_DISPLAYED : String = "extra_info_displayed"

# Define the actual signal.
#warning-ignore:unused_signal
signal extra_info_displayed(title_text, info_text)
