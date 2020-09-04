extends PanelContainer

onready var text : RichTextLabel = $Vert/BBText
onready var title_node : Label = $Vert/Top/Title

var current_page : int = 1
var total_pages_in_data : int = 0

#A tooltip has been pressed. Show myself and get everything ready.
func _activate(tooltip_data : TooltipData) -> void :
	#Make myself visible and clear the old data.
	text.bbcode_text = ""
	title_node.text = ""
	show()
	
	#Set current page to 1 and determine how many pages are in the data.
	current_page = 0
	total_pages_in_data = tooltip_data.bbtext_fields.size()
	
	#Set the text display to the first entry of the data.
	if tooltip_data.bbtext_fields.size() > 0 :
		text.bbcode_text = tooltip_data.bbtext_fields[current_page - 1]
	
	#Make the title on the display match the title in the data.
	title_node.text = tooltip_data.title

#Connect to signals.
func _ready() -> void :
	#Listen for when tooltip has been requested.
	Signals.Hud.connect(Signals.Hud.TOOLTIP_MENU_DISPLAYED, self, "_activate") 
	
	#Listen for the different buttons in the menu.
	$Vert/Bottom/Quit.connect("pressed", self, "hide")
