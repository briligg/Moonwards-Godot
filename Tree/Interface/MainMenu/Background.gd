extends TextureRect


#Where the texture files are located.
const FILE_LOC : String = "res://Assets/Interface/Textures/MainMenuBackgrounds/"

#These are the textures that we will be loading
var textures : Array = []
var current_texture : int = 0

#How long to wait before cycling to the next background.
var wait : float = 2

#Cycle through the texts on a set timer.
func _process(delta : float) -> void :
	wait -= delta
	if wait <= 0 :
		wait = 2
		
		#Move onto the next texture.
		current_texture += 1
		if current_texture >= textures.size() :
			current_texture = 0
		
		texture = textures[current_texture]

#Load the StreamTextures to display them later.
func _ready() -> void :
	var dir : Directory = Directory.new()
	dir.open(FILE_LOC)
	dir.list_dir_begin(true)
	var next_file : String = dir.get_next()
	while next_file != "" :
		var stream : StreamTexture = load(FILE_LOC + next_file)
		if not stream == null : 
			textures.append(stream)
		
		next_file = dir.get_next()
	
	pass
