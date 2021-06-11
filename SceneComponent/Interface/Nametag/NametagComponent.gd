extends AComponent

onready var switch_context : SwitchContextEPI = entity.request_epi(EPIManager.SWITCH_CONTEXT_EPI)

func _init().("NametagComponent", false):
	pass
	
func _ready() -> void:
	call_deferred("set_name", entity.entity_name)
	
	#Only be visible if I am not over the main player
	if is_net_owner() :
		visible = false
	
	switch_context.connect(switch_context.CONTEXT_DATA_GIVEN, self, "context_data_given")

#Called when another client has given me new context data.
func context_data_given(player_name : String) -> void :
	set_name(player_name)
	visible = true

func set_name(name) -> void:
	$Nametag3D.set_name(name)
