extends Area
class_name ReversingVisibilityTrigger

export(bool) var pause_on_error: bool = false

export(Array, NodePath) var show_lod0_list
export(Array, NodePath) var show_lod1_list
export(Array, NodePath) var show_lod2_list

export(Array, NodePath) var hide_list

var _previous_states: Dictionary = {}

var is_set: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_validate_paths(show_lod0_list)
	_validate_paths(hide_list)
	self.connect("body_entered", self, "on_body_entered")
	self.connect("body_exited", self, "on_body_exited")
	for n in get_children():
		if n is Area:
			n.connect("body_entered", self, "on_body_entered")
			n.connect("body_exited", self, "on_body_exited")

func on_body_entered(body) -> void:
	if body is AEntity:
		if body.owner_peer_id == get_tree().get_network_unique_id():
			Log.trace(self, "on_body_entered", "Reversing visibility states for %s, in %s"
					%[body.name, self.name])
			process_visibility()
		
func on_body_exited(body) -> void:
	if body is AEntity:
		if body.owner_peer_id == get_tree().get_network_unique_id():
			Log.trace(self, "on_body_exited", "Processing visibility for %s, in %s"
					%[body.name, self.name])
			reverse_visibility()
	
func process_visibility() -> void:
	if is_set:
		return;
	is_set = true;
	
	for path in show_lod0_list:
		_process_lod_node(path, 0)
	for path in show_lod1_list:
		_process_lod_node(path, 1)
	for path in show_lod2_list:
		_process_lod_node(path, 2)
	for path in hide_list:
		_process_lod_node(path, 255)

func reverse_visibility() -> void:
	is_set = false;
	
	for node in _previous_states.keys():
		var state = _previous_states[node]
		node.call_deferred("set_lod", state)
	_previous_states.clear()

func _process_lod_node(path, lod_level) -> void:
	var node = get_node(path)
	if node is LodModel:
		_previous_states[node] = node.lod_state
		node.call_deferred("set_lod", lod_level)
		Log.trace(self, "process_rvt_node", "Node %s set to lod level: %s." %[path, lod_level]) 
	else:
		Log.warning(self, "process_rvt_node", "Node %s is not a LodModel." %path) 

func _validate_paths(path_list: Array):
	for path in path_list:
		if get_node(path) == null:
			Log.error(self, "", "RVT Path %s is inavlid in %s." %[path, self.name])
			if pause_on_error:
				assert(false)
