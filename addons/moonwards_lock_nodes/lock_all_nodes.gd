tool
extends EditorPlugin

var open_scene
var lock_button
var unlock_button

const lock_button_scene = preload("res://addons/moonwards_lock_nodes/lock_all_btn.tscn")
const unlock_button_scene = preload("res://addons/moonwards_lock_nodes/unlock_all_btn.tscn")

func _ready() -> void :
	#Keep up to date with the open scenes.
	connect("scene_changed", self, "_on_scene_changed")

func _enter_tree():
	lock_button = lock_button_scene.instance()
	unlock_button = unlock_button_scene.instance()
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, lock_button)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, unlock_button)
	
	lock_button.connect("pressed", self, "on_lock_pressed")
	unlock_button.connect("pressed", self, "on_unlock_pressed")

func _exit_tree():
	if lock_button:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, lock_button)
		lock_button.queue_free()
	if unlock_button:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, unlock_button)
		unlock_button.queue_free()

func _on_scene_changed(scene: Node) -> void :
	open_scene = scene
	if scene == null:
		return

func on_lock_pressed():
	_lock_recursive(open_scene)

func on_unlock_pressed():
	_unlock_recursive(open_scene)

func _lock_recursive(scene: Node) -> void:
	_lock_node(scene)
	for node in scene.get_children():
		_lock_node(node)
		if node.get_child_count() > 0:
			_lock_recursive(node)

func _lock_node(node: Node) -> void:
	node.set_meta("_edit_lock_", true)

func _unlock_recursive(scene: Node) -> void:
	_unlock_node(scene)
	for node in scene.get_children():
		_unlock_node(node)
		if node.get_child_count() > 0:
			_unlock_recursive(node)

func _unlock_node(node: Node) -> void:
	node.remove_meta("_edit_lock_")
