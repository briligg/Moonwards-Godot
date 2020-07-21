extends Reference
class_name HudSignals

### Until we or godot implements proper class_name handling
const name = "Hud"

# Define the signal's string name.
const CHAT_TYPING_STARTED : String = "chat_typing"
const CHAT_TYPING_FINISHED : String = "chat_finished_typing"
const EXTRA_INFO_DISPLAYED : String = "extra_info_displayed"
const HIDDEN_HUDS_SET : String = "hidden_huds_set"
const HIDE_INTERACTS_MENU_REQUESTED: String = "hide_interacts_menu_requested"
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"
const INTERACT_POSSIBLE : String = "interact_possible"
const INTERACT_BECAME_IMPOSSIBLE : String = "interact_became_impossible"
const INTERACT_OCCURED : String = "interact_occured"
const NEW_INTERACTOR_GRABBED_FOCUS : String = "new_interactor_grabbed_focus"
const POTENTIAL_INTERACT_REQUESTED : String = "potential_interact_requested"
const VISIBLE_HUDS_SET : String = "visible_huds_set"

# Define the actual signal.
#warning-ignore:unused_signal
signal chat_finished_typing()
signal chat_typing()
#warning-ignore:unused_signal
signal extra_info_displayed(title_text, info_text)
signal hidden_huds_set(hide_flag_int)
signal hide_interacts_menu_requested()
signal interactable_entered_reach(interactable_node)
signal interactable_left_reach(interactable_node)
signal interact_possible(interaction_info_string)
signal interact_became_impossible()
signal interact_occured(interactable_user_node)
signal new_interactor_grabbed_focus(new_interactor_component_node)
signal potential_interact_requested(potential_interact_array)
signal visible_huds_set(show_flag_int)
