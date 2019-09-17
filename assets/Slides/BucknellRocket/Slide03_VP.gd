extends Spatial

func _ready():
	$Body/RocketBody/PYBB_Nozzle_Opt.hide()
	$Body/RocketBody/RocketScoop.hide()
	$Body/RocketBody/ThrustFanBlades_Opt.hide()
	
	$Body/RocketBody/VariableInlet/AnimationPlayer.play("Key.005Action.001")
