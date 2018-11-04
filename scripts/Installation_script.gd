extends Spatial
var collision = preload("res://addons/CeransDev/MakeCollisionShapes.gd")

func get_all_meshes(node):
	var meshes = []
	var array2 = []
	for child in node.get_children():
		print(child)
		if child is MeshInstance:
			meshes.append(child)
		if child.get_child_count() > 0:
			array2 = get_all_meshes(child)
			for element in array2:
				meshes.append(element)
	if meshes.size() != 0:
		return meshes
	else: 
		print("Non fatal array error: Array is empty")
		
func _ready():
	#var directory = Directory.new();
	yield() 
	yield()
	
	
	#var doFileExists = directory.file_exists("res://Firstrun.txt")
	#if not doFileExists:
	#	pass
	get_all_meshes(self)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
