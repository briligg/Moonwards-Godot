extends Node
var collision = preload("res://addons/CeransDev/MakeCollisionShapes.gd")


func _ready():
	var directory = Directory.new();
	var doFileExists = directory.file_exists("res://Firstrun.txt")
	if not doFileExists:
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
