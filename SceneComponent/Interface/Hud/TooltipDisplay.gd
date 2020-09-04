extends PanelContainer

onready var text : RichTextLabel = $Vert/BBText


#A tooltip has been pressed. Show myself and get everything ready.
func _activate(tooltip_data : String) -> void :
	#Make myself visible and clear the old data.
	text.bbcode_text = ""
	show()
	
	text.bbcode_text = tooltip_data

#Connect to signals.
func _ready() -> void :
	#Listen for when tooltip has been requested.
	Signals.Hud.connect(Signals.Hud.TOOLTIP_MENU_DISPLAYED, self, "_activate") 
	
	#Listen for the different buttons in the menu.
	$Vert/Bottom/Quit.connect("pressed", self, "hide")
