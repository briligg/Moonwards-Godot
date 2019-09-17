extends Control

var index = 0

func _ready():
	update_slides()

func update_slides():
	if index != 0 and index < $Slides.get_child_count():
		$Slides.get_child(index-1).visible = false
		if not $Prev.visible:
			$Prev.visible = true
	elif index == 0:
		$Prev.visible = false
	if index < $Slides.get_child_count()-1:
		$Slides.get_child(index+1).visible = false
		$Next.visible = true
	else:
		$Next.visible = false
	if index < $Slides.get_child_count():
		$Slides.get_child(index).visible = true
		

func _on_Button_pressed():
	index += 1
	update_slides()


func _on_Prev_pressed():
	index -= 1
	update_slides()
