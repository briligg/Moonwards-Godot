tool
extends Skeleton

export(bool) var play_ik setget _start
export(bool) var stop_ik setget _stop

func _start(_val):
	for node in get_children():
		if node is SkeletonIK:
			node.start()
			
func _stop(_val):
	for node in get_children():
		if node is SkeletonIK:
			node.stop()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node is SkeletonIK:
			node.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
