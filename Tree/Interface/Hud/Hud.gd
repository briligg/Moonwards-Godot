extends CanvasLayer

#Do not set these children's visibility.
onready var visibility_autonomy : Array = [$Blur, $RadialBackground, $RadialSelector]


var _active: bool = false

#Listen for when Hud hide calls are made.
func _ready() -> void :
	Signals.Hud.connect(Signals.Hud.HIDDEN_HUDS_SET, self, "_set_hud_visibility") 

#Set hud visibility by menu. Right now only uses AllButTutorial
func _set_hud_visibility(hud_flag : int, is_visible : bool) -> void :
	var enums : EnumHelper = EnumHelper.new()
	#Toggle all but hud visibilty.
	if enums.has_flag(hud_flag, Hud.flags.AllExceptTutorial) :
		if is_visible :
			show()
		else :
			hide()
		
		#Hide the tutorial menu if everything else is being shown.
		#Otherwise show the tutorial menu.
		$GeneralInfo.tutorial_menu_active(!is_visible)

func show() -> void:
	for child in get_children():
		if child is Control and not visibility_autonomy.has(child):
			child.visible = true

func hide() -> void:
	for child in get_children():
		if child is Control and not visibility_autonomy.has(child):
			child.visible = false

func set_active(state: bool) -> void:
	_active = state
	
	if _active:
		show()
	else:
		hide()
