extends Node


#Determines what parts of the Hud you are referring to.
enum flags {
	Chat = 0,
	InteractsMenu = 1,
	InteractsDisplay = 2,
	All = 4,
	InteractsAll = 8,
	Rollback = 16
}

var current_visibility : int = flags.All
var previous_visibility : int = flags.All


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
