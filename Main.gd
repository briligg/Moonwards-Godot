extends Node
"""
	Boot Scene Script
	Initializes headless server if required
"""

export(PackedScene) var menu_scene

func _ready() -> void:
	get_tree().change_scene(menu_scene.resource_path)
