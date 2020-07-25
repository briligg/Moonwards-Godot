extends Spatial


onready var chat : Spatial = $ChatComponent
onready var interact_display : Label = $InteractDisplay
onready var interacts_menu : PanelContainer = $InteractsMenu

var help : EnumHelper = EnumHelper.new()


#Listen for when huds visibility requests happen.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.VISIBLE_HUDS_SET, self, "_set_huds_visibility", [true])
	Signals.Hud.connect(Signals.Hud.HIDDEN_HUDS_SET, self, "_set_huds_visibility", [false])

#Called from signal. Sets the requested Huds to the requested visibility state.
func _set_huds_visible(flag : int, visibility : bool) -> void :
	if help.has_flag(flag, Hud.flags.Chat) :
		chat.visible = visibility
	
	#Set all interacts related menus.
	if help.has_flag(flag, Hud.flags.InteractsAll) :
		interact_display.visible = visibility
		interacts_menu.visible = visibility
	
	if help.has_flag(flag, Hud.flags.InteractsDisplay) :
		interact_display.visible = visibility
	
	if help.has_flag(flag, Hud.flags.InteractsMenu) :
		interacts_menu.visible = visibility
	
	#flag requests all huds. Cycle through everything and set it's visibility.
	if help.has_flag(flag, Hud.flags.All) :
		for call in [Hud.flags.Chat, Hud.flags.InteractsAll] :
			_set_huds_visible(call, visibility)
