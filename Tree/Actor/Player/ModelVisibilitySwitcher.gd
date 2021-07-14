extends Node

const MODEL_PATH  = "../ModelComponent/Model/Female_Player/Skeleton/"

#Temporary solution for showing the model.
#This lets us keep ControllableBodyComponenet modular.

func _ready() -> void :
	var comp : ControllableBodyComponent = get_parent().get_node("ControllableBodyComponent")
	comp.connect(comp.CONTROL_TAKEN, self, "_control_taken")
	comp.connect(comp.CONTROL_LOST, self, "_control_lost")

func _control_taken(taker : AEntity) -> void :
	#Setup variables for easy model access.
	var models_parent = taker.get_node("ModelComponent/Model/Female_Player/Skeleton")
	var model : MeshInstance #Taler's model
	var my_model : MeshInstance
	
	#Get whether I should show the male body or the female body.
	if models_parent.get_node("Male_Player_LOD0").visible :
		model = models_parent.get_node("Male_Player_LOD0")
		my_model = get_node(MODEL_PATH+"MaleBody-LOD0")
	else :
		model = models_parent.get_node("FemaleBody-LOD0")
		my_model = get_node(MODEL_PATH+"FemaleBody-LOD0")
	
	#Switch visibility to my model. I do not need to call taker model
	my_model.show()
	
	#Update the model to have correct materials.
	for i in range(0,4) :
		var prop : String = "material/%s"%str(i)
		my_model.set(prop, model.get(prop))

func _control_lost() -> void :
	get_node(MODEL_PATH+"MaleBody-LOD0").hide()
	get_node(MODEL_PATH+"FemaleBody-LOD0").hide()
