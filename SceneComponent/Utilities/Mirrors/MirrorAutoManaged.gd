extends Spatial
class_name WorldMirror

export(float) var DistanceCap := 100.0 setget set_DistanceCap
export(float) var CamRenderCap := 100.0 setget set_CamRenderCap
export(float) var CamHeight := 200.0 setget set_CamHeight
export(Vector3) var Angle := Vector3(0.0,0.0,0.0) setget set_Angle
export(Vector3) var Angle_Target := Vector3(0.0,0.0,0.0) setget set_AngleTarget

export(Color) var ColorMod := Color(1.0,1.0,1.0,1.0) setget set_ColorMod


onready var localViewport = $Viewport
onready var localPlane = $MeshInstance
onready var localCamera = $Viewport/Camera 
var playerCamera

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
	
func set_ColorMod(value : Color) -> void:
	ColorMod = value

func printTexture():
	if localViewport != null and localPlane != null:
		localPlane.get_surface_material(0).set_shader_param("Texture",localViewport.get_texture())
		localPlane.get_surface_material(0).set_shader_param("Color",ColorMod)
		return
	else:
		return

func getMainData():
	playerCamera = get_tree().get_root().get_viewport().get_camera() 
	#var playerLoc
	#if is_instance_valid(playerCam):
	#	playerLoc = playerCam.get_global_transform().origin
	#else:
	#	playerLoc = Vector3.ZERO
	if localCamera != null:
		pass
		#localCamera.position = 
		#localCamera.get_position_in_parent()
		#localCamera.transform = Transform(Vector3(0.0,CamHeight,0.0),self.transform.origin) #localCamera.transform.origin()
		#localCamera.current = true
	

func _ready() -> void:
	if not Engine.is_editor_hint():
		print("Mirror Executed (In-Game)")
		getMainData()
		printTexture()
	else:
		printTexture()
		return


func _process(delta : float) -> void:
	if not Engine.is_editor_hint():
		var playerLoc
		if is_instance_valid(playerCamera):
			playerLoc = playerCamera.get_global_transform().origin
			printTexture()
		else:
			playerLoc = Vector3.ZERO
			return

func _enter_tree():
	pass

func _exit_tree():
	pass
