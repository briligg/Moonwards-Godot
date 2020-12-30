extends Reference
class_name HudSignals

### Until we or godot implements proper class_name handling
const name = "Hud"

# Define the signal's string name.
const CHAT_TYPING_STARTED : String = "chat_typing"
const CHAT_TYPING_FINISHED : String = "chat_finished_typing"
const EXTRA_INFO_DISPLAYED : String = "extra_info_displayed"
const FLIGHT_VALUE_SET : String = "flight_value_set"
const HIDDEN_HUDS_SET : String = "hidden_huds_set"
const HIDE_INTERACTS_MENU_REQUESTED: String = "hide_interacts_menu_requested"
const HIDE_RETICLE : String = "hide_reticle"
const INTERACTABLE_DISPLAY_HIDDEN : String = "interactable_display_hidden"
const INTERACTABLE_DISPLAY_SHOWN : String = "interactable_display_shown"
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"
const INTERACT_OCCURED : String = "interact_occured"
const MAP_VISIBILITY_SET : String = "map_visibility_set"
const NEW_INTERACTOR_GRABBED_FOCUS : String = "new_interactor_grabbed_focus"
const SET_FIRST_PERSON : String = "set_first_person"
const SET_FIRST_PERSON_POSSIBLE_CLICK : String = "set_first_person_possible_click"
const SET_FIRST_PERSON_POSSIBLE_INTERACT : String = "set_first_person_possible_interact"
const START_ELEMENT_WINDOW : String = "start_element_window"
const TOOLTIP_MENU_DISPLAYED : String = "tooltip_menu_displayed"

# Define the actual signal.
#warning-ignore:unused_signal
signal chat_finished_typing()
signal chat_typing()
#warning-ignore:unused_signal
signal extra_info_displayed(title_text, info_text)
signal flight_value_set(new_value_float)
signal hidden_huds_set(huds_affect_flag_int, became_visible)
signal hide_interacts_menu_requested()
signal hide_reticle()
signal interactable_display_hidden()
signal interactable_display_shown(interactable_title, uses_interacts_menu_only_bool)
signal interactable_entered_reach(interactable_node)
signal interactable_left_reach(interactable_node)
signal interact_occured(interactable_user_node)
signal map_visibility_set(became_visible_bool)
signal new_interactor_grabbed_focus(new_interactor_component_node)
signal set_first_person(is_active_bool)
signal set_first_person_possible_click(click_is_possible_bool)
signal set_first_person_possible_interact(interact_is_possible_bool)
signal start_element_window(new_scene_node)
signal tooltip_menu_displayed(tooltip_data)
