extends Spatial
class_name WorldMirror

export(float) var DistanceCap := 1000.0 setget set_DistanceCap
export(float) var CamRenderCap := 1000.0 setget set_CamRenderCap
export(float) var CamHeight := 1000.0 setget set_CamHeight
export(Vector3) var Angle := Vector3(0.0,0.0,0.0) setget set_Angle
export(Vector3) var Angle_Target := Vector3(0.0,0.0,0.0) setget set_AngleTarget

func set_DistanceCap(value : float) -> void:
	DistanceCap = value
	
func set_CamRenderCap(value : float) -> void:
	CamRenderCap = value

func set_CamHeight(value : float) -> void:
	CamHeight = value
	
func set_Angle(value : Vector3) -> void:
	Angle = value
	
func set_AngleTarget(value : Vector3) -> void:
	Angle_Target = value

func _ready() -> void:
	if not Engine.is_editor_hint():
		print("Mirror Executed (In-Game)")
	else:
		pass


func _process(delta : float) -> void:
	if not Engine.is_editor_hint():
		pass
	

func getMainData():
	var playerCam = get_tree().get_root().get_viewport().get_camera() 
	var playerLoc
	if is_instance_valid(playerCam):
		playerLoc = playerCam.get_global_transform().origin
	else:
		playerLoc = Vector3.ZERO

func _enter_tree():
	pass

func _exit_tree():
	pass
