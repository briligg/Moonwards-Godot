extends Spatial

func _ready():
	$Body/RocketBody/RocketScoop.hide()
	$Body/RocketBody/ThrustFanBlades_Opt.hide()
	$Body/RocketBody/VariableInlet.hide()
	
	$Body/RocketBody/PYBB_Nozzle_Opt/AnimationPlayer.play("Key.004Action.001")
