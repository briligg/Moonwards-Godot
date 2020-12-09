extends Area
class_name ReversingVisibilityTrigger

export(bool) var pause_on_error: bool = false

export(Array, NodePath) var show_lod0_list
export(Array, NodePath) var show_lod1_list
export(Array, NodePath) var show_lod2_list

export(Array, NodePath) var hide_list

# For non-LOD nodes
export(Array, NodePath) var force_hide_list
export(Array, NodePath) var force_show_list

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
	if VisibilityManager.disable_all_triggers:
		return
	
	if body is AEntity:
		if body.owner_peer_id == Network.network_instance.peer_id:
			process_visibility()
			if  VisibilityManager.log_vt_changes:
				Log.trace(self, "on_body_entered", "Reversing visibility states for %s, in %s"
						%[body.name, self.name])

func on_body_exited(body) -> void:
	if VisibilityManager.disable_all_triggers:
		return
		
	if body is AEntity:
		if body.owner_peer_id == Network.network_instance.peer_id:
			reverse_visibility()
			if VisibilityManager.log_vt_changes:
				Log.trace(self, "on_body_exited", "Processing visibility for %s, in %s"
						%[body.name, self.name])
	
func process_visibility() -> void:
	if is_set:
		return;
	is_set = true;
	var c = 0
	for path in show_lod0_list:
		_process_lod_node(path, 0)
		if c % VisibilityManager.iterations_per_frame == 0:
			yield(get_tree(), "idle_frame")
		c += 1
	for path in show_lod1_list:
		_process_lod_node(path, 1)
		if c % VisibilityManager.iterations_per_frame == 0:
			yield(get_tree(), "idle_frame")
		c += 1
	for path in show_lod2_list:
		_process_lod_node(path, 2)
		if c % VisibilityManager.iterations_per_frame == 0:
			yield(get_tree(), "idle_frame")
		c += 1
	for path in hide_list:
		_process_lod_node(path, 255)
		if c % VisibilityManager.iterations_per_frame == 0:
			yield(get_tree(), "idle_frame")
		c += 1
	for path in force_hide_list:
		# Where false is node.visibility
		_process_lod_node(path, false)
		if c % VisibilityManager.iterations_per_frame == 0:
			yield(get_tree(), "idle_frame")
		c += 1
	for path in force_show_list:
		# Where true is node.visibility
		_process_lod_node(path, true)
		if c % VisibilityManager.iterations_per_frame == 0:
			yield(get_tree(), "idle_frame")
		c += 1

func reverse_visibility() -> void:
	is_set = false;
	
	var c = 0
	for node in _previous_states.keys():
		var state = _previous_states[node]
		_reverse_node_visibility(node, state)
#		node.call_deferred("set_lod", state)
		if c % VisibilityManager.iterations_per_frame == 0:
			yield(get_tree(), "idle_frame")
		c += 1
	_previous_states.clear()

func _reverse_node_visibility(node, state):
	if node is LodModel:
		node.call_deferred("set_lod", state)
	else:
		node.visible = state

func _process_lod_node(path, state) -> void:
	var node = get_node(path)
	if node is LodModel:
		_previous_states[node] = node.lod_state
		node.call_deferred("set_lod", state)
		if VisibilityManager.log_vt_changes:
			Log.debug(self, "process_rvt_node", "Node %s set to lod level: %s." %[path, state]) 
	elif node != null:
		_previous_states[node] = node.visible
		node.visible = state
		if VisibilityManager.log_vt_changes:
			Log.debug(self, "process_rvt_node", "Node %s set to visibility: %s." %[path, state]) 

func _validate_paths(path_list: Array):
	for path in path_list:
		if get_node(path) == null:
			Log.error(self, "", "RVT Path %s is inavlid in %s." %[path, self.name])
			if pause_on_error:
				assert(false)
