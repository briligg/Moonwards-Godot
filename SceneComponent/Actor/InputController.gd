extends AComponent
class_name InputController

func _init().("InputController", true):
	pass

func _ready():
	pass
func _process(_delta):
	entity.input = Vector3.ZERO
	handle_input()

func handle_input() -> void:
	if Input.is_action_pressed("jump"):
		entity.input.y += 1
		
	if Input.is_action_pressed("move_forwards"):
		entity.input += entity.transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		entity.input += -entity.transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		entity.input += entity.transform.basis.x
	elif Input.is_action_pressed("move_right"):
		entity.input += -entity.transform.basis.x 

	# Account for diagonal movement
	
	#rset("horizontal_vector", horizontal_vector)
