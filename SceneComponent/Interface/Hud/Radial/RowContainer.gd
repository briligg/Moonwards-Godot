extends VBoxContainer


var rows_confirmed : Array = []

func _ready() -> void :
	var id : int = 0
	for child in get_children() :
		if child is HBoxContainer :
			rows_confirmed.append(false)
			child.connect("button_selected", self, "_row_confirmed", [id])
			id += 1
	
	#Listen for confirm pressed
	$Confirm.connect("pressed", get_parent(), "toggle_visibility")

func _row_confirmed(id : int) -> void :
	rows_confirmed[id] = true
	
	#Check that all rows are confirmed.
	if rows_confirmed.find(false) == -1 :
		for row in get_children() :
			if row is HBoxContainer :
				row.deselect_buttons()
		
		get_parent().toggle_visibility()

func reset() :
	var id : int = 0
	for row in get_children() :
		if row is HBoxContainer :
			row.deselect_buttons()
			rows_confirmed[id] = false
			id += 1
	
