extends Reference
class_name HudSignals

### Until we or godot implements proper class_name handling
const name = "Hud"

# Define the signal's string name.
const CHAT_TYPING_STARTED : String = "chat_typing"
const CHAT_TYPING_FINISHED : String = "chat_finished_typing"
const EXTRA_INFO_DISPLAYED : String = "extra_info_displayed"
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"
const INTERACT_POSSIBLE : String = "interact_possible"
const INTERACT_BECAME_IMPOSSIBLE : String = "interact_became_impossible"
const INTERACT_OCCURED : String = "interact_occured"
const POTENTIAL_INTERACT_REQUESTED : String = "potential_interact_requested"

# Define the actual signal.
#warning-ignore:unused_signal
signal chat_finished_typing()
signal chat_typing()
#warning-ignore:unused_signal
signal extra_info_displayed(title_text, info_text)
signal interactable_entered_reach(interactable_node)
signal interactable_left_reach(interactable_node)
signal interact_possible(interaction_info_string)
signal interact_became_impossible()
signal interact_occured(interactable_user_node)
#Interact was pressed when multiple interactables are potentially interactable.
signal potential_interact_requested(potential_interact_array)
