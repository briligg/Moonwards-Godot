extends Spatial

onready var left_front = $LeftFrontWheel
onready var left_mid = $LeftMidWheel
onready var left_back = $LeftBackWheel
onready var right_front = $RightFrontWheel
onready var right_mid = $RightMidWheel
onready var right_back = $RightBackWheel

func _physics_process(_delta):
#	if left_front.get_collider():
	left_front.global_transform.origin.y = left_front.get_collision_point ().y
	left_mid.global_transform.origin.y = left_mid.get_collision_point ().y
	left_back.global_transform.origin.y = left_back.get_collision_point ().y
	right_front.global_transform.origin.y = right_front.get_collision_point ().y
	right_mid.global_transform.origin.y = right_mid.get_collision_point ().y
	right_back.global_transform.origin.y = right_back.get_collision_point ().y
