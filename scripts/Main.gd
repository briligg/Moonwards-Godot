extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Run_pressed():
	$ui/main.hide()
	$ui/loading.show()
	$load_timer.start()

func _on_Timer_timeout():
	get_tree().change_scene("res://MainFlyCamera.tscn")


func _on_Help_pressed():
	if $ui/main/pHelp.visible :
		$ui/main/pHelp.hide()
	else:
		$ui/main/pHelp.show()
