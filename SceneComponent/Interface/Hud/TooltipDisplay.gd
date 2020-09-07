extends PanelContainer

onready var text : RichTextLabel = $Vert/BBText
onready var title_node : Label = $Vert/Top/Title
onready var page_node : Label = $Vert/Bottom/Page

#All the tooltip data currently in use.
var current_data : TooltipData

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
	page_node.text = str(current_page+1) + "/" + str(total_pages_in_data)
	
	#Set the text display to the first entry of the data.
	if tooltip_data.bbtext_fields.size() > 0 :
		text.bbcode_text = tooltip_data.bbtext_fields[current_page]
	
	#Make the title on the display match the title in the data.
	title_node.text = tooltip_data.title
	
	#Keep a memory of the current tooltip and watch for if it gets freed.
	if current_data != null :
		current_data.disconnect("freed", self, "_tooltip_freed")
	current_data = tooltip_data
	tooltip_data.connect("freed", self, "_tooltip_freed")

#Listen for input when I am visible. This controls paging, scrolling, and exitting.
func _input(event : InputEvent) -> void :
	#Move to the previous page.
	if event.is_action_pressed("ui_page_down") || event.is_action_pressed("ui_left") :
		page_change(-1)
	
	#Move to the next page.
	elif event.is_action_pressed("ui_page_up") || event.is_action_pressed("ui_right") :
		page_change(1)
	
	elif event.is_action_pressed("ui_cancel") :
		close_display()

#Connect to signals.
func _ready() -> void :
	#Listen for when tooltip has been requested.
	Signals.Hud.connect(Signals.Hud.TOOLTIP_MENU_DISPLAYED, self, "_activate") 
	
	#Listen for the different buttons in the menu.
	$Vert/Bottom/Quit.connect("pressed", self, "close_display")
	$Vert/Top/PageLeft.connect("pressed", self, "page_change", [-1])
	$Vert/Top/PageRight.connect("pressed", self, "page_change", [1])

#Called by TooltipData signal when the currently displayed Tooltip is freed.
func _tooltip_freed() -> void :
	current_data = null
	close_display()

func close_display() -> void :
	hide()

#Change current page by the amount of pages specified by the integer.
func page_change(move_pages : int) -> void :
	# warning-ignore:narrowing_conversion
	current_page = clamp(current_page + move_pages, 0, total_pages_in_data - 1)
	text.bbcode_text = current_data.bbtext_fields[current_page]
	page_node.text = str(current_page + 1) + "/" + str(total_pages_in_data)
