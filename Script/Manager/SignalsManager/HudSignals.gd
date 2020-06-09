extends Reference
class_name HudSignals

### Until we or godot implements proper class_name handling
const name = "Hud"

# Define the signal's string name.
const CHAT_TYPING_STARTED : String = "chat_typing"
const CHAT_TYPING_FINISHED : String = "chat_finished_typing"
const EXTRA_INFO_DISPLAYED : String = "extra_info_displayed"
const INTERACT_POSSIBLE : String = "interact_possible"
const INTERACT_BECAME_IMPOSSIBLE : String = "interact_became_impossible"

# Define the actual signal.
#warning-ignore:unused_signal
signal chat_finished_typing()
signal chat_typing()
#warning-ignore:unused_signal
signal extra_info_displayed(title_text, info_text)
signal interact_possible(interaction_info_string)
signal interact_became_impossible()
