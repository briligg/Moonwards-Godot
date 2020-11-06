extends Spatial
export(NodePath) var hatch_collision_path
onready var hatch_collision = get_node(hatch_collision_path)

onready var anim = get_parent().get_node("Model/AnimationPlayer")

var is_hatch_open: bool = false

func _ready() -> void:
	$Interactable.connect("interacted_by", self, "interacted_by")


func interacted_by(interactor):
	if is_hatch_open:
		close_hatch()
	else:
		open_hatch()

func close_hatch():
	anim.play("Close")
	is_hatch_open = false
	hatch_collision.disabled = false
	$Interactable.display_info = "Open Hatch"

func open_hatch():
	anim.play("Open")
	is_hatch_open = true
	hatch_collision.disabled = true
	$Interactable.display_info = "Close Hatch"
