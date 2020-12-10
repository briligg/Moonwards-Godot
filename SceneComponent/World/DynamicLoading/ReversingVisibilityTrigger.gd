extends Area
class_name ReversingVisibilityTrigger

export(Array, NodePath) var show_lod0_list
export(Array, NodePath) var show_lod1_list
export(Array, NodePath) var show_lod2_list

export(Array, NodePath) var hide_list

var _previous_states: Dictionary = {}

var is_set: bool = false

# Called when the node enters the scene tree for the first time.
func _ready()-> void:
	_validate_paths(show_lod0_list)
	_validate_paths(show_lod1_list)
	_validate_paths(show_lod2_list)

	_validate_paths(hide_list)
	
	yield(Signals.Loading, Signals.Loading.WORLD_POST_READY)
#	return
	self.connect("body_entered", self, "on_body_entered")
	self.connect("body_exited", self, "on_body_exited")
	for n in get_children():
		if n is Area:
			n.connect("body_entered", self, "on_body_entered")
			n.connect("body_exited", self, "on_body_exited")

func on_body_entered(body)-> void:
	if VisibilityManager.disable_all_triggers:
		return
	
	if body is AEntity:
		if body.owner_peer_id == Network.network_instance.peer_id:
			process_visibility()
			if  VisibilityManager.log_vt_changes:
				Log.trace(self, "on_body_entered", "Reversing visibility states for %s, in %s"
						%[body.name, self.name])

func on_body_exited(body)-> void:
	if VisibilityManager.disable_all_triggers:
		return
		
	if body is AEntity:
		if body.owner_peer_id == Network.network_instance.peer_id:
			reverse_visibility()
			if VisibilityManager.log_vt_changes:
				Log.trace(self, "on_body_exited", "Processing visibility for %s, in %s"
						%[body.name, self.name])
	
func process_visibility()-> void:
	if is_set:
		return;
	is_set = true;
	for path in show_lod0_list:
		var node = get_node(path)
		_process_visibility_recursive(node, VisibilityManager.LodState.LOD0)

	for path in show_lod1_list:
		var node = get_node(path)
		_process_visibility_recursive(node, VisibilityManager.LodState.LOD1)

	for path in show_lod2_list:
		var node = get_node(path)
		_process_visibility_recursive(node, VisibilityManager.LodState.LOD2)

	for path in hide_list:
		var node = get_node(path)
		_process_visibility_recursive(node, VisibilityManager.LodState.HIDDEN)


func reverse_visibility()-> void:
	is_set = false;
	
	for node in _previous_states.keys():
		var visibility_state = _previous_states[node]
		_reverse_node_visibility(node, visibility_state)
	_previous_states.clear()

func _reverse_node_visibility(node, visibility_state):
	if node is LodModel:
		node.call_deferred("set_lod", visibility_state)

func _process_visibility_recursive(node, visibility_state)-> void:
	if node is LodModel:
		node.call_deferred("set_lod", visibility_state)
		_process_lod_node(node, visibility_state)
		
	var children = node.get_children()
	if children.empty():
		return
		
	for child in children:
		if child is LodModel:
			_process_lod_node(child, visibility_state)
		_process_visibility_recursive(child, visibility_state)

func _process_lod_node(node, visibility_state)-> void:
	if node is LodModel:
		_previous_states[node] = node.lod_state
		node.call_deferred("set_lod", visibility_state)

func _validate_paths(path_list: Array):
	for path in path_list:
		if get_node(path) == null:
			Log.error(self, "", "Path %s is inavlid in RVT %s." %[path, self.name])
			path_list.erase(path)
			if VisibilityManager.pause_on_error:
				assert(false)
