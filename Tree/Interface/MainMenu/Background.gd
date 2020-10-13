extends Control


#Where the texture files are located.
const FILE_LOC : String = "res://Assets/Interface/Textures/MainMenuBackgrounds/"

#These are the two texture rects.
onready var anim : AnimationPlayer = $A
onready var one : TextureRect = get_node("1")
onready var two : TextureRect = get_node("2")
onready var timer : Timer = $Timer

#These are the textures that we will be loading
var textures : Array = []
var current_texture : int = 0

#Determines which texture to we are suppose to change.
var change_one : bool = false

#How long to wait before cycling to the next background.
var wait : float = 2

#Move to the next picture in the list.
func _next_picture() -> void :
	#Move onto the next texture.
		current_texture += 1
		if current_texture >= textures.size() :
			current_texture = 0
		
		#Change the shown picture.
		if change_one :
			change_one = false
			one.texture = textures[current_texture]
			anim.play_backwards("Modulate")
		else :
			change_one = true
			two.texture = textures[current_texture]
			anim.play("Modulate")

#Load the StreamTextures to display them later.
func _ready() -> void :
	var dir : Directory = Directory.new()
	dir.open(FILE_LOC)
	dir.list_dir_begin(true)
	var next_file : String = dir.get_next()
	while next_file != "" :
		if not next_file.get_extension() == "import" : #Don't load the import files
			var stream : StreamTexture = load(FILE_LOC + next_file)
			textures.append(stream)
		
		next_file = dir.get_next()
	
	#Make the first and second picture have the correct texture.
	if textures.size() >= 1 :
		one.texture = textures[0]
		current_texture = 0
	if textures.size() >= 2 :
		two.texture = textures[1]
		current_texture = 1
	
	#Let the timer decide when to change the picture.
	timer.connect("timeout", self, "_next_picture")
	
	
