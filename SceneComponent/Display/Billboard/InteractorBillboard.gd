tool
extends Spatial


export var text_content : String = "Billboard\nContent" setget set_text


#Setup the scene according to specifications.
func _ready() -> void :
	var label : Label = $Viewport/InteractorBillboardContent/Label
	label.text = text_content

func set_text(new_text : String) -> void :
	var label : Label = $Viewport/InteractorBillboardContent/Label
	var label_text : String = new_text
	while label_text.find("\\n", 0) != -1 :
		var at : int = label_text.find("\\n", 0)
		label_text.erase(at, 2)
		label_text = label_text.insert(at, "\n")
	
	label.text = label_text
	text_content = new_text
