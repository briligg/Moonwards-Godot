extends Spatial
class_name WorldMirror

export(bool) var SimpleMirror := true setget set_SimpleMirror
export(bool) var MirrorEffect := true setget set_MirrorEffect
export(bool) var TickCapture := true setget set_TickCapture
export(float) var DistanceCap := 100.0 setget set_DistanceCap
export(float) var CamRenderCap := 100.0 setget set_CamRenderCap
export(float) var CamHeight := 100.0 setget set_CamHeight
export(float) var CamErrorBias := 3.5 setget set_CamErrorBias

export(Color) var ColorMod := Color(1.0,1.0,1.0,1.0) setget set_ColorMod


onready var localViewport = $Viewport
onready var localPlane = $MeshInstance
onready var localCamera = $Viewport/Camera 
var playerCamera

func set_SimpleMirror(value : bool) -> void:
	SimpleMirror = value
	
func set_TickCapture(value : bool) -> void:
	TickCapture = value

func set_DistanceCap(value : float) -> void:
	DistanceCap = value
	
func set_CamRenderCap(value : float) -> void:
	CamRenderCap = value

func set_CamHeight(value : float) -> void:
	CamHeight = value
	
func set_CamErrorBias(value : float) -> void:
	CamErrorBias = value
	
func set_ColorMod(value : Color) -> void:
	ColorMod = value
	
func set_MirrorEffect(value : bool) -> void:
	MirrorEffect = value


func printTexture():
	if localViewport != null and localPlane != null:
		localPlane.get_surface_material(0).set_shader_param("Texture",localViewport.get_texture())
		localPlane.get_surface_material(0).set_shader_param("Color",ColorMod)
		return
	else:
		return

func getMirrorEffect():
	#Fast transform calc for simple mirror
	var cTransform = Transform(Vector3(-1.0,0.0,0.0),Vector3(0.0,0.0,-1.0),Vector3(0.0,-1.0,0.0),Vector3(0.0,CamHeight,0.0))
	#var cTransform = Transform(Basis(), Vector3(0.0,CamHeight,0.0)) #self.transform.origin
	
	# Simple mirror in case of projection only needed, or earth directional system
	if SimpleMirror:
		localCamera.set_global_transform(cTransform)
		localCamera.set_frustum(1.0, Vector2(0.0,0.0), 0.38, 800.0)
		return
	
	# Player camera location, based on the LODs manager
	var playerCamPos = Vector3.ZERO
	if is_instance_valid(playerCamera):
		playerCamPos = playerCamera.get_global_transform().origin
	else:
		localCamera.set_global_transform(cTransform)
		localCamera.set_frustum(1.0, Vector2(0.0,0.0), 0.38, 800.0)
		return
	
	# Main parameters to compute reflection alike mirror
	var mTransform = Transform(Basis(), Vector3.ZERO)
	var mSize = 4.0
	if is_instance_valid(localPlane):
		mTransform = localPlane.get_global_transform()
		mSize = localPlane.get_aabb().size.x
	
	var mNormal = mTransform.basis.z.normalized()
	var mPlane = Plane(mNormal, mTransform.origin.dot(mNormal))
	
	var mOffset = mTransform.xform_inv(playerCamPos)
	mOffset = Vector2(-mOffset.x,-mOffset.y)
	var mProjection = mPlane.project(playerCamPos)
	var mPosition = playerCamPos + (mProjection - playerCamPos) * CamErrorBias
	
	cTransform = Transform(Basis(), mPosition)
	cTransform = cTransform.looking_at(mProjection, mTransform.basis.y.normalized())
	
	if is_instance_valid(localCamera):
		localCamera.set_global_transform(cTransform)
		localCamera.set_frustum(mSize, mOffset, mProjection.distance_to(playerCamPos), 800.0) #localPlane.scale.get get the scale rather automatically
		return


func getMainData():
	#playerCamera = get_tree().get_root().get_viewport().get_camera() 
	playerCamera = get_tree().get_root().get_camera()
	if playerCamera != null:
		print("Mirror: Player Camera Found")
	if localCamera != null:
		print("Mirror: Local Camera Found")
		if SimpleMirror:
			localCamera.set_global_transform(Transform(Vector3(-1.0,0.0,0.0),Vector3(0.0,0.0,-1.0),Vector3(0.0,-1.0,0.0),Vector3(0.0,CamHeight,0.0)))
		else:
			localCamera.set_global_transform(Transform(Vector3(1.0,0.0,0.0),Vector3(0.0,1.0,0.0),Vector3(0.0,0.0,-1.0),Vector3(0.0,CamErrorBias,0.0)))
		if localViewport != null:
			if MirrorEffect:
				localViewport.size.x = 1024
				localViewport.size.y = 2560
			else:
				localViewport.size.x = 1024*2
				localViewport.size.y = 2560*2
		#localCamera.get_position_in_parent()
		#localCamera.current = true
	

func _ready() -> void:
	if not Engine.is_editor_hint():
		print("Mirror Executed (In-Game)")
		getMainData()
		printTexture()
		return
	else:
		printTexture()
		return


func _process(_delta : float) -> void:
	if not Engine.is_editor_hint():
		if TickCapture:
			getMirrorEffect()
			printTexture()
		return

func _enter_tree():
	return

func _exit_tree():
	return
