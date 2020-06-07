extends Spatial

func _ready():
	$Body/RocketBody/PYBB_Nozzle_Opt.hide()
	$Body/RocketBody/RocketScoop.hide()
	$Body/RocketBody/VariableInlet.hide()
	
	$Body/RocketBody/ThrustFanBlades_Opt/AnimationPlayer.play("ThrustFanBlades_OptAction.001")
