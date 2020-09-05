extends Node
class_name TooltipData

signal freed()

var bbtext_fields : PoolStringArray = []

var title : String


func free_myself() -> void :
	emit_signal("freed")
	queue_free()
