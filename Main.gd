extends Node
"""
	Boot Scene Script
	Initializes headless server if required
"""

func _ready() -> void:
	get_tree().change_scene(Scene.main_menu)
