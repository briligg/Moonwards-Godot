extends Node

#Easy access to checking if a value is contained in current_visibility.
var enum_helper : EnumHelper = EnumHelper.new()

#Determines what parts of the Hud you are referring to.
enum flags {
	Chat = 1,
	AppMenusAll = 2,
	AppMenusThatBlur = 4 #Hides App menus that blur the background.  
	InteractsDisplay = 8,
	RadialMenu = 16,
	All = 32, #Hide everything hud related.
	Rollback = 64
}

var current_visibility : int = flags.All
var previous_visibility : int = flags.All


#Lets huds know if they are included in the call.
func has_flag(calling_hud_flag : int) -> bool :
	return enum_helper.has_flag(calling_hud_flag, current_visibility)

#Make certain Hud menus hide.
func hide(hide_flag : int) -> void :
	if hide_flag == flags.Rollback :
		hide_flag = previous_visibility
	
	previous_visibility = current_visibility
	current_visibility = hide_flag
	
	Signals.Hud.emit_signal(Signals.Hud.HIDDEN_HUDS_SET, hide_flag)

#Make certain Hud menus show themselves.
func show(show_flag : int) -> void :
	if show_flag == flags.Rollback :
		show_flag = previous_visibility
	
	previous_visibility = current_visibility
	current_visibility = show_flag
	
	Signals.Hud.emit_signal(Signals.Hud.VISIBLE_HUDS_SET, show_flag)
