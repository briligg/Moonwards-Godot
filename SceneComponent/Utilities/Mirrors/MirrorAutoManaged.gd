extends Spatial
class_name LODManager_GD

export(float) var Mirror_DistanceCap := 1000.0 setget set_LODDistanceMax


func _ready() -> void:
	if not Engine.is_editor_hint():
		print("Mirror Executed (In-Game)")
	else:
		pass


func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		#PlayerCamEditor = get_tree().root.get_child(0).get_viewport().get_camera()
		#PlayerCamEditor = get_tree().get_edited_scene_root().get_parent().get_camera()
		#print(PlayerCamEditor.trans)
		#print(PlayerCamEditor)
		if not LODsEditorSet:
			#_editor_function()
			pass
		else:
			#print(PlayerCamEditor.get_camera_transform().origin)
			pass
			#_editorTick_function()
	

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
