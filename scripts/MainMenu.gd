extends Control

onready var main_ui : Node = $VBoxContainer

func _ready() -> void:
	UIManager.register_base_ui(self)
	UIManager._set_current_ui(main_ui)